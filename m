From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: cpsw forwards broadcasts on all interfaces in dual_emac mode
Date: Mon, 02 Jun 2014 09:32:08 +0200
Message-ID: <538C2878.903@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Altenberg <jan@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38818 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbaFBHcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 03:32:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan,

I've been playing with the dual_emac mode and I noticed that if eth0
receives broadcasts packets then it will forward them to eth1. I assume
that it either has one ALE rule too much or is missing one. Do you have
any idea what it might be?

Sebastian
