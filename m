From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_htb: turn intermediate classes into leaves
Date: Thu, 30 Nov 2006 13:26:34 +0100
Message-ID: <456ECDFA.9080207@trash.net>
References: <20061127070401.GA1886@ff.dom.local> <456ABA07.1010508@trash.net> <20061128063948.GA1818@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37059 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936368AbWK3M0k
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 07:26:40 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061128063948.GA1818@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> [NET_SCHED] sch_htb:
> 
> [PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]
> 
> - turn intermediate classes into leaves again when their
>   last child is deleted (struct htb_class changed)

Looks good to me too, but it still seems to be missing
class level adjustment after deletion. The classification
function refuses to queue packets to classes with level > 0.
