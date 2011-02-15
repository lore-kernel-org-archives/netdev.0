From: Markku Pesonen <tourula@gmail.com>
Subject: 3x59x WOL and CONFIG_SUSPEND
Date: Tue, 15 Feb 2011 15:55:39 +0200
Message-ID: <4D5A85DB.7070309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47232 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab1BON4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 08:56:49 -0500
Received: by eye27 with SMTP id 27so68605eye.19
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 05:56:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Since commit 074037ec79bea73edf1b1ec72fef1010e83e3cc5
(PM / Wakeup: Introduce wakeup source objects and event statistics (v3)),
Wake-On-Lan on my 3c905C has not worked unless I enable CONFIG_SUSPEND.
The driver says "0000:00:0b.0: WOL not supported."

Enabling CONFIG_SUSPEND makes Wake-On-Lan work on 2.6.37 while 2.6.36
works just fine without it. Is this a regression or intended behavior?


