From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: why dev_watchdog() timer freezes TX queues
Date: Thu, 17 Mar 2011 20:25:02 +0100
Message-ID: <4D82600E.2010902@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab1CQTZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 15:25:35 -0400
Received: by wya21 with SMTP id 21so3121292wya.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 12:25:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is it required to set FROZEN all tx queues in dev_watchdog() timer?
On timeout netif_tx_lock() blocks TX on all queues, even if STOPPED
was not set on any queue.

Jean-Mickael


