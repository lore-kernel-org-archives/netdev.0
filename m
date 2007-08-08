From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC] allow device to stop packet mirror behaviour
Date: Wed, 08 Aug 2007 03:17:55 -0700 (PDT)
Message-ID: <20070808.031755.91441405.davem@davemloft.net>
References: <1186475155.4067.17.camel@johannes.berg>
	<20070807.180607.116354128.davem@davemloft.net>
	<1186564441.11717.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1186564441.11717.5.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 08 Aug 2007 11:14:01 +0200

> On Tue, 2007-08-07 at 18:06 -0700, David Miller wrote:
> > From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > Date: Tue, 07 Aug 2007 10:25:55 +0200
> > 
> > > The only way to solve this problem therefore seems to be to suppress the
> > > mirroring out of the packet by dev_queue_xmit_nit(). The patch below
> > > does that by way of adding a new netdev flag.
> > 
> > Multicast packets also get looped back in a similar manner in the ipv4
> > code.  These will also be seen twice due to this issue.
> 
> I don't think these other places are of any interest because of the
> radiotap+802.11 framing on the devices where it is relevant to us; you
> can't actually add an IP route to a monitor interface as far as I can
> tell.

Then I don't understand your problem.  If they are specific 802.11
protocol packets, the radio stack is in a much better situation to
filter out things like this.
