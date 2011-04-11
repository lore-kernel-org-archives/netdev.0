From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 NEXT 2/8] qlcnic: fix eswitch stats
Date: Mon, 11 Apr 2011 16:09:46 -0700
Message-ID: <20110411160946.7a2ec69a@nehalam>
References: <1286205297-23214-1-git-send-email-amit.salecha@qlogic.com>
	<1286205297-23214-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37893 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609Ab1DKXKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 19:10:03 -0400
In-Reply-To: <1286205297-23214-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  4 Oct 2010 08:14:51 -0700
Amit Kumar Salecha <amit.salecha@qlogic.com> wrote:

> +
> +#define QLCNIC_ADD_ESW_STATS(VAL1, VAL2)\
> +do {	\
> +	if (((VAL1) == QLCNIC_ESW_STATS_NOT_AVAIL) && \
> +	    ((VAL2) != QLCNIC_ESW_STATS_NOT_AVAIL)) \
> +		(VAL1) = (VAL2); \
> +	else if (((VAL1) != QLCNIC_ESW_STATS_NOT_AVAIL) && \
> +		 ((VAL2) != QLCNIC_ESW_STATS_NOT_AVAIL)) \
> +			(VAL1) += (VAL2); \
> +} while (0)

Fugly macro. Make it an inline function?
