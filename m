From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Mon, 27 Sep 2010 12:32:45 -0700
Message-ID: <OF871D4733.876C9DA0-ON882577AB.006AB200-882577AB.006B6101@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <20100922215052.GK11157@obsidianresearch.com> <alpine.DEB.2.00.1009231026510.32567@router.home> <20100923172603.GM11157@obsidianresearch.com> <alpine.DEB.2.00.1009231230100.2962@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009231230100.2962-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote on 09/23/2010 10:37:28 AM:

> 
> If all unsolicited igmp reports are lost then the router will
> only start forwarding the mc group after the reporting intervals
> (which could be in the range of minutes) when it triggers igmp reports
> through a general igmp query. Until that time the MC group looks dead. 
And
> people and software may conclude that the **** network is broken.

        You can, of course, add a querier (or configure it, assuming
an attached switch supports it) and set the query interval and robustness
count as appropriate for that network.

> This is a general issue for any network where configurations for MC
> forwarding is needed and where initial igmp reports may get lost.

Meaning "IB-only", right? :-) Maybe other NBMA networks too, but
certainly not a typical problem for typical networks (i.e., Ethernet).

> A staggering of time intervals would be a general solution to that 
issue.

As would be having those networks queue packets for hardware addresses 
they
know require a delay before a transmit can complete. But that approach 
can't
adversely affect already-working solutions for typical networks, or
depart unnecessarily from established standard protocols.

 +-DLS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
