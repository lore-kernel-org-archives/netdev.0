From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 10:01:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618080118.GC23037@wotan.suse.de>
References: <20030617220420.GA1169@averell> <20030617.150751.52901849.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, netdev@oss.sgi.com, mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030617.150751.52901849.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 03:07:51PM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@muc.de>
>    Date: Wed, 18 Jun 2003 00:04:20 +0200
> 
>    Convert pppoe to a new style protocol, otherwise it is unusable 
>    on SMP compiled kernels because of the printk in deliver*old_ones.
>    It works fine here, but only tested on a UP box.
> 
> Please don't add new skb_linearize() users, I'm trying
> to make that only local to net/core/dev.c

Then offer a flag or something for protocols that also doesn't trigger
printks ?


> 
> Otherwise I'm fine with your patch.

How else should it be done? 

I'm not going through the whole PPP layer now to audit it for non linear
skb cleanliness...

-Andi
