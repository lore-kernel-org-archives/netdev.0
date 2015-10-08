From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/6] net: dsa: push switchdev prepare phase in
 FDB ops
Date: Thu, 8 Oct 2015 15:47:10 +0200
Message-ID: <20151008134710.GL2186@nanopsycho.orion>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151008.052839.1028977184279787835.davem@davemloft.net>
 <20151008133250.GB1275@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, andrew@lunn.ch,
	narmstrong@baylibre.com, sergei.shtylyov@cogentembedded.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151008133250.GB1275@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 08, 2015 at 03:32:51PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi David,
>
>On Oct. Thursday 08 (41) 05:28 AM, David Miller wrote:
>> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> Date: Wed,  7 Oct 2015 19:48:25 -0400
>> 
>> > The first 3 patches removes the dsa.h include from linux/netdevice.h, which
>> > broke the inclusion of switchdev.h in dsa.h.
>> 
>> I still don't agree with bloating up struct netdevice just to deal with
>> an include file ordering issue, sorry.
>
>Yes, I just saw your reply on the first version. I will resend the
>patchset with the forward declarations instead.
>
>But looking at the issue that Jiri and the kbuild bot pointed out
>earlier in the thread, we must agree that having the DSA header in
>netdevice.h is wrong.
>
>There are 2 points to note here:
>
>* checking a "rcv" member of a DSA-specific structure to anwser the
>  question "does this interface uses hardware-inserted tag?" is not
>  generic and not robust at all.
>
>* the "dsa_ptr" of net_device is just used to access the dsa_switch_tree
>  from DSA packet_type receive functions. There must be another way to
>  pass it, maybe from a netdev_priv or the packet_type->af_packet_priv?

I sent previously patch for this:
http://patchwork.ozlabs.org/patch/336940/
So now my patch would have another user :)

Vivien, I will refresh the patch and send it to you, the you can
use the priv by dsa and send my patch along with your patchset. How does
that sound?
