From: Stefan Roese <stefan.roese@gmail.com>
Subject: Problem with am335x (cpsw) MDIO state machine
Date: Fri, 22 Nov 2013 17:06:08 +0100
Message-ID: <528F80F0.7010003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:10682 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801Ab3KVQGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 11:06:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All!

I'm currently struggling with the MDIO interface of the am335x SoC. As
its state machine continuously communicates with the potentially
available PHY devices (0...31). To determine the link status etc. But
I'm trying to communicate with am SMSC9303 switch via this MDIO
interface. It has 32bit registers organized as 2 16bit registers. These
registers need to be accessed back-to-back. Without any other frame in
between. And this is often interrupted (disturbed) by these state
machines polling frames.

Has anyone ever tried to work in this SoC with this MDIO state machine
disabled? I tried this by clearing the ENABLE bit in the MDIOCONTROL
register after each transaction. But this doesn't seem to work
(resulting in timeouts etc)?

Has anybody ever tried anything like this?

Thanks,
Stefan
