From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: NAPI and ->poll()
Date: Tue, 08 Jul 2008 15:27:23 +0200
Message-ID: <m3vdzgfqv8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57188 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753035AbYGHN12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 09:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just noticed a weird fragment in my code and want to be sure:
The NAPI poll() method should _always_ return a number of sk_buffs
processed, even if it calls netif_rx_complete() and then maybe
netif_rx_reschedule()?
-- 
Krzysztof Halasa
