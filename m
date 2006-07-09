From: Robert Schulze <rob@net-pr.de>
Subject: Re: [PATCH] airo: make debug-like messages printed by	airo_print_dbg()
Date: Mon, 10 Jul 2006 00:23:17 +0200
Message-ID: <44B181D5.5070007@net-pr.de>
References: <44AFD651.8030801@net-pr.de> <1152455044.2519.7.camel@localhost.localdomain> <44B13974.9090604@net-pr.de> <44B1431D.3010405@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p15181122.pureserver.info ([212.227.60.11]:40601 "EHLO
	p15181122.pureserver.info") by vger.kernel.org with ESMTP
	id S1161188AbWGIWR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 18:17:56 -0400
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <44B1431D.3010405@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

ok lets keep that message to be visible to anybody, but put it into one line.
Thanks for your comments.
Now, I will track down what causes the error on my machine, I think it has something todo with pcmcia...

with kind regards,

Robert Schulze

--- linux-2.6.17.1/drivers/net/wireless/airo.c.orig	2006-07-08 14:02:12.000000000 +0200
+++ linux-2.6.17.1/drivers/net/wireless/airo.c	2006-07-10 00:19:15.000000000 +0200
@@ -3897,11 +3897,10 @@ static u16 issuecommand(struct airo_info
  	pRsp->rsp1 = IN4500(ai, RESP1);
  	pRsp->rsp2 = IN4500(ai, RESP2);
  	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
-		airo_print_err(ai->dev->name, "cmd= %x\n", pCmd->cmd);
-		airo_print_err(ai->dev->name, "status= %x\n", pRsp->status);
-		airo_print_err(ai->dev->name, "Rsp0= %x\n", pRsp->rsp0);
-		airo_print_err(ai->dev->name, "Rsp1= %x\n", pRsp->rsp1);
-		airo_print_err(ai->dev->name, "Rsp2= %x\n", pRsp->rsp2);
+		airo_print_err(ai->dev->name,
+			"cmd:%x status:%x rsp0:%x rsp1:%x rsp2:%x"
+			pCmd->cmd, pRsp->status, pRsp->rsp0, pRsp->rsp1,
+			pRsp->rsp2);
  	}

  	// clear stuck command busy if necessary
