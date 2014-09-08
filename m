From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Mon, 08 Sep 2014 10:43:03 -0400
Message-ID: <540DC077.2060500@oracle.com>
References: <20140902161936.GA31516@oracle.com> <20140904.223724.206826043871814498.davem@davemloft.net> <20140908143802.GF31377@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29037 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbaIHOnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 10:43:09 -0400
In-Reply-To: <20140908143802.GF31377@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/08/2014 10:38 AM, Sowmini Varadhan wrote:
>
> I'm not sure where we stand with this- do I need to resubmit any/all of 
> those two patches?

Dave,
	FWIW, I think there may be a memory barrier issue (missing rmb()),
which I'll look into and patch separately, if needed, but I don't think it
has anything to do with this patchset.

My original concern about the wmb() placement was wrong, I agree.

							+-DLS
