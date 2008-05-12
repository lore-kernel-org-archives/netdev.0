From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH next-2.6 3/3] [SCTP]: add sctp/remaddr table to
	complete RFC remote address table OID
Date: Mon, 12 May 2008 10:37:36 -0400
Message-ID: <20080512143736.GA26305@hmsreliant.think-freely.org>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com> <1210360566-16661-3-git-send-email-vladislav.yasevich@hp.com> <20080509.151518.202869638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3564 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840AbYELOiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 10:38:04 -0400
Content-Disposition: inline
In-Reply-To: <20080509.151518.202869638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2008 at 03:15:18PM -0700, David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri,  9 May 2008 15:16:06 -0400
> 
> > Add support for RFC3873 remote address table OID.
> > 
> >       +--(5) sctpAssocRemAddrTable
> >       |   |
> >       |   |--(-) sctpAssocId (shared index)
> >       |   |
> >       |   +--(1) sctpAssocRemAddrType (index)
> >       .   |
> >       .   +--(2) sctpAssocRemAddr (index)
> >       .   |
> >           +--(3) sctpAssocRemAddrActive
> >           |
> >           +--(4) sctpAssocRemAddrHBActive
> >           |
> >           +--(5) sctpAssocRemAddrRTO
> >           |
> >           +--(6) sctpAssocRemAddrMaxPathRtx
> >           |
> >           +--(7) sctpAssocRemAddrRtx
> >           |
> >           +--(8) sctpAssocRemAddrStartTime
> > 
> > This patch places all the requsite data in /proc/net/sctp/remaddr.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> Applied.

Dave, where is this applied?  I don't see it in either your net or net-next
trees?

Thanks & Regards
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
