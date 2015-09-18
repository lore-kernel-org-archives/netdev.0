From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
Date: Fri, 18 Sep 2015 09:36:42 +0000
Message-ID: <BLUPR03MB14759657A388F648ED6928FDE2590@BLUPR03MB1475.namprd03.prod.outlook.com>
References: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0110.outbound.protection.outlook.com ([207.46.100.110]:61883
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751714AbbIRJgo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 05:36:44 -0400
In-Reply-To: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Kevin Hao [mailto:haokexin@gmail.com]
> Sent: Friday, September 18, 2015 3:43 PM
> To: netdev@vger.kernel.org
> Cc: Florian Fainelli; Xie Shaohui-B21989
> Subject: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
> 
> This reverts commit 1298267b548a78840bd4b3e030993ff8747ca5e6.
> 
> That commit claim that the Vitesse VSC8641 is compatible with Vitesse
> 82xx. But this is not true. It seems that all the registers used in
> Vitesse phy driver are not compatible between 8641 and 82xx.
[S.H] There are differences between some register's bit define. 
But some are not used by driver. 

> It does cause malfunction of the Ethernet on p1010rdb-pa board.
[S.H] Which exact register's setting caused problem? If it needs different setting,
It can be handled by distinguishing phy_id, or replacing relative API for VSC8641.

Thanks!
Shaohui
