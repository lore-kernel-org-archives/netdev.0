From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: Re: [PATCH 3/7] [DCCP]: Introduce dccp_probe
Date: Fri, 22 Sep 2006 11:00:26 -0300
Message-ID: <20060922140025.GC1828@mandriva.com>
References: <200609221428.02022.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:48786 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S932494AbWIVOAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 10:00:46 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
In-Reply-To: <200609221428.02022.ian.mcdonald@jandi.co.nz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 02:28:01PM +1200, Ian McDonald wrote:
> This adds DCCP probing shamelessly ripped off from TCP probes by Stephen
> Hemminger.
> 
> I've put in here support for further CCID3 variables as well.
> Andrea/Arnaldo might look to extend for CCID2.
> 
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied after renaming net/dccp/dccp_probe.c to net/dccp/probe.c for
consistency, the resulting module remains dccp_probe.ko

I guess we should try at some point to consolidate the code in these
probes tho.

- Arnaldo
