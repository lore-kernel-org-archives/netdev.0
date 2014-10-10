From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: Micrel KSZ8031 - phy link missing
Date: Fri, 10 Oct 2014 10:31:55 +0000
Message-ID: <915054555B5659448ACF8A70E114824D0163C7A77B@Exchange2010.kamstrup.dk>
References: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk>
 <5437A7A2.3020700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Angelo Dureghello <angelo70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:24771 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaJJKb6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 06:31:58 -0400
In-Reply-To: <5437A7A2.3020700@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey

> i still have the issue after patching kernel 3.17.
> ...
> I am using RMII in my custom board, don't know if it makes any difference.

What RMII clock source do you use? MAC, PHY or external?

If your MAC output the RMII clock you need to enable MICREL_PHY_50MHZ_CLK flag in phydev->dev_flags.


Venlig hilsen / Best regards

Kamstrup A/S <http://www.kamstrup.dk> 
Bruno Thomsen
Development engineer
Technology

Kamstrup A/S
Industrivej 28
DK-8660 Skanderborg
Tel:	 +45 89 93 10 00	 
Fax:	 +45 89 93 10 01	 
Dir:	 +45 89 93 13 94	 
E-mail:	 bth@kamstrup.dk	 
Web:	 www.kamstrup.dk
