From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: keyboard dead with 45b5035
Date: Mon, 18 Feb 2008 18:53:05 +0100
Message-ID: <20080218185305.48a67587@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Laszlo Attila Toth <panther@balabit.hu>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:50585 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbYBRRxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 12:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch "[RTNETLINK]: Send a single notification on device state changes." kills (at least) the keyboard here. Everything seems to work fine in single user mode, but when init starts spawning of logins, the keyboard goes bye-bye. Even the power button is ignored. :/

I've tried just creating another vt with "chvt 2", but that is insufficient to trigger the bug.

Rgds
-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org
