From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/3] gianfar: Fix the way the local advertising
 flow options are determined
Date: Thu, 23 Oct 2014 12:36:49 +0300
Message-ID: <5448CC31.20201@freescale.com>
References: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
 <1414051077-4330-2-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Matei Pavaluca <matei.pavaluca@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0117.outbound.protection.outlook.com ([157.56.111.117]:25851
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750799AbaJWJg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 05:36:57 -0400
In-Reply-To: <1414051077-4330-2-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 10:57 AM, Matei Pavaluca wrote:
> From: Pavaluca Matei <matei.pavaluca@freescale.com>
>
> Local flow control options needed in order to resolve the negotiation
> are incorrectly calculated.
>
> Previously 'mii_advertise_flowctrl' was called to determine the local advertising
> options, but these were determined based on FLOW_CTRL_RX/TX flags which are
> never set through ethtool.
> The patch simply translates from ethtool flow options to mii flow options.
>
> Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>

Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
