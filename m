From: lin jason <kernel.jason@gmail.com>
Subject: How to enable phy's interrupt correctly using phylib?
Date: Mon, 2 Apr 2012 16:16:12 +0800
Message-ID: <CAGCDX1=iVH_JRq_QzrEqMnX31fBSgV9kpvsw8NP1raJR88O55g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64856 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab2DBIQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 04:16:12 -0400
Received: by iagz16 with SMTP id z16so3794097iag.19
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 01:16:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear:
The design is a MAC connected to a Marvell phy.
Phy's interrupt will be triggered for some conditions, like link status changed,
and then it will trigger MAC's interrupt.
But phy itself has no direct interrupt connected to CPU.
I used phylib to implement the network driver (MAC driver).
When link status changed, I need to do something in MAC's irq.
In linux 2.6.36, I used phy_enable_interrupts() in MAC driver.
But after linux 2.6.37, this function is not used directly by any drivers.

Interrupt connection:
PHY ------> MAC ------> CPU

How to enable phy's interrupt correctly using phylib?
