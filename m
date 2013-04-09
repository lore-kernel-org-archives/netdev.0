From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: introduce uapi header for sctp
Date: Tue, 9 Apr 2013 14:04:29 -0400
Message-ID: <20130409180429.GC11337@neilslaptop.think-freely.org>
References: <1365522841-19549-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47789 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab3DISEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 14:04:44 -0400
Content-Disposition: inline
In-Reply-To: <1365522841-19549-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 05:54:01PM +0200, Daniel Borkmann wrote:
> This patch introduces an UAPI header for the SCTP protocol,
> so that we can facilitate the maintenance and development of
> user land applications or libraries, in particular in terms
> of header synchronization.
> 
> To not break compatibility, some fragments from lksctp-tools'
> netinet/sctp.h have been carefully included, while taking care
> that neither kernel nor user land breaks, so both compile fine
> with this change (for lksctp-tools I tested with the old
> netinet/sctp.h header and with a newly adapted one that includes
> the uapi sctp header). lksctp-tools smoke test run through
> successfully as well in both cases.
> 
> Suggested-by: Neil Horman <nhorman@tuxdriver.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Yup, Thanks Daniel.  Davids already applied it, but FWIW
Acked-by: Neil Horman <nhorman@tuxdriver.com>
