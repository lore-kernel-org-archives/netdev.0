From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH] gianfar: fix the last transmit buffer descriptor
Date: Thu, 2 Jun 2016 11:02:05 +0000
Message-ID: <DB4PR04MB3798034BE5D0B62715CD53596580@DB4PR04MB379.eurprd04.prod.outlook.com>
References: <1464860188-47854-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Yangbo Lu <yangbo.lu@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0056.outbound.protection.outlook.com ([157.56.112.56]:7947
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753091AbcFBLCK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 07:02:10 -0400
In-Reply-To: <1464860188-47854-1-git-send-email-yangbo.lu@nxp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Yangbo Lu [mailto:yangbo.lu@nxp.com]
>Sent: Thursday, June 02, 2016 12:36 PM
>To: netdev@vger.kernel.org
>Cc: Claudiu Manoil <claudiu.manoil@freescale.com>; Yangbo Lu
><yangbo.lu@nxp.com>
>Subject: [PATCH] gianfar: fix the last transmit buffer descriptor
>
>When the transmit hardware timestamping is enabled, an additional
>TxBD would be added and would be set as the last TxBD with TXBD_LAST
>and TXBD_INTERRUPT. However this has been broken by a patch recently.
>This made the software couldn't get transmit hardware timestamps and
>resulted in call trace. So, this patch is to fix this issue.
>
>Fixes: 48963b4492e9 ("gianfar: Remove redundant ops for do_tstamp
>       from xmit()")
Thanks.

Reviewed-by: Claudiu Manoil <claudiu.manoil@nxp.com>
