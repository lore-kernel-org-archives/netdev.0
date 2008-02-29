From: "Syed Khader" <Syed.Khader@conexant.com>
Subject: smc911x Driver Disables Receiving After FIFO Overrun
Date: Fri, 29 Feb 2008 12:20:46 +0530
Message-ID: <02C837E0D6BC6741BD574EB1E35D900F021E49AF@hyd-mail2.bbnet.ad>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnxtsmtp5.conexant.com ([198.62.9.40]:41070 "EHLO
	cnxtsmtp5.conexant.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757894AbYB2HJB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 02:09:01 -0500
Received: from CPS (wsmx2.nb.conexant.com [157.152.185.17]) (using TLSv1 with cipher RC4-MD5 (
 128/128 bits)) (No client certificate requested) by cnxtsmtp5.conexant.com (Tumbleweed MailGate
 3.5.1) with ESMTP id 2E33B1BF90C for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 22:50:56 -0800 (
 PST)
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  The problem is with smc911x.c driver from 2.6.18.2 kernel running on
arm9 having a smsc 9117/9115 device.
   At high xfer rates, when there is rx overrun the driver just disables
rx(using SMC_SET_MAC_CR), it doesn't reenable it, and the driver stops
working.
   I have tried to fix this problem by reenable rx, but I don't know
where exactly to do it. 
   If anyone has worked on smsc, please suggest.
  
Thanks
Syed

Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer **************************** 

"This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 

********************************************************************** 

---------------------------------------------------------------------

