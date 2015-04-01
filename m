From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] cxgb4: Move ethtool related code to a separate
 file
Date: Wed, 01 Apr 2015 00:42:02 -0700
Message-ID: <1427874122.31790.8.camel@perches.com>
References: <1427892333-26330-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com, varun@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0245.hostedemail.com ([216.40.44.245]:42642 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751474AbbDAHmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:42:06 -0400
In-Reply-To: <1427892333-26330-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-01 at 18:15 +0530, Hariprasad Shenai wrote:
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

A couple trivial bits:

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
[]
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
> @@ -0,0 +1,915 @@
> +/*
> + *  Copyright (C) 2013-2014 Chelsio Communications.  All rights reserved.

2015 ?

[]

> +static char stats_strings[][ETH_GSTRING_LEN] = {

be nice to make this const one day.

> +	"TxOctetsOK         ",
> +	"TxFramesOK         ",
> +	"TxBroadcastFrames  ",
> +	"TxMulticastFrames  ",
> +	"TxUnicastFrames    ",
> +	"TxErrorFrames      ",
