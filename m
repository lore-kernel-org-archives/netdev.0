From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv6 net-next 20/31] iw_cxgb4: adjust tcp snd/rcv window
 based on link speed
Date: Wed, 12 Mar 2014 18:12:45 -0400 (EDT)
Message-ID: <20140312.181245.1921772176964395946.davem@davemloft.net>
References: <008801cf3e2e$d8679b00$8936d100$@opengridcomputing.com>
	<20140312.162348.2225551653125401290.davem@davemloft.net>
	<008d01cf3e3a$257edc90$707c95b0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <008d01cf3e3a$257edc90$707c95b0$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Date: Wed, 12 Mar 2014 16:29:27 -0500

>> >> You can just use the TCP settings the kernel already provides for
>> >> the real TCP stack.
>> >
>> > Do you mean use sysctl_tcp_*mem, sysctl_tcp_timestamps, sysctl_tcp_window_scaling,
> etc?
>> > I'll look into this.
>> 
>> And the socket memory limits, which we use to compute default window
>> sizes.
> 
> How's this look (compile-tested only)?  Note I had to export some of the tcp limits.

Well, the problem is that you've dug your own hole already.

You can't just remove these existing module parameters that users can
set.  They are user visible APIs, you can't just remove them.

The best you can do is stop adding new ones.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
