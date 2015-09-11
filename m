From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv2 RFC] RTEXT_FILTER_SKIP_STATS support to avoid dumping
 inet/inet6 stats
Date: Fri, 11 Sep 2015 15:32:25 -0400
Message-ID: <20150911193225.GA9687@oracle.com>
References: <20150910213429.GH28585@oracle.com>
 <55F322FC.1050509@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	jose.marchesi@oracle.com
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30735 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbbIKTch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 15:32:37 -0400
Content-Disposition: inline
In-Reply-To: <55F322FC.1050509@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/12/15 00:22), Raghavendra K T wrote:
> 
> Sowmini, Thanks for the patch which is more cleaner way without
> breaking current behaviour.
> 
> [ Though RTEXT_FILTER_NEED_STATS flag with reverse effect  would have
> helped immediately :)]

Agree, but existing legacy usage will not set this flag, so I had 
few choices here.

> /me waits for the RTEXT_FILTER_SKIP_STATS to be supported in
> gccgo/golang, so that it can be used in docker newNetlinkRequest() to
> exploit this.

yes, I'm working on lining up the glibc bit as well (thus the cc to Jose..)
I'll send out the non-rfc version in a bit..

thanks for the feedback!

--Sowmini
