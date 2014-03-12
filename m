From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv6 net-next 20/31] iw_cxgb4: adjust tcp snd/rcv window
 based on link speed
Date: Wed, 12 Mar 2014 16:23:48 -0400 (EDT)
Message-ID: <20140312.162348.2225551653125401290.davem@davemloft.net>
References: <1394639446-6504-21-git-send-email-hariprasad@chelsio.com>
	<20140312.155017.118512327402563943.davem@davemloft.net>
	<008801cf3e2e$d8679b00$8936d100$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <008801cf3e2e$d8679b00$8936d100$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Date: Wed, 12 Mar 2014 15:08:33 -0500

>> > Added module option named adjust_win, defaulted to 1, that allows
>> > disabling the 40G window bump.  This allows a user to specify the exact
>> > default window sizes via module options snd_win and rcv_win.
>> 
>> This is terrible.  As is the existing other TCP tweaking module
>> parameters.
>> 
>> You can just use the TCP settings the kernel already provides for
>> the real TCP stack.
> 
> Do you mean use sysctl_tcp_*mem, sysctl_tcp_timestamps, sysctl_tcp_window_scaling, etc?
> I'll look into this.  

And the socket memory limits, which we use to compute default window
sizes.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
