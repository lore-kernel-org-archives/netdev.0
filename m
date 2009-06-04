From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 0/3] sis190 gigabit fixes(bug 9735,11149) and new phy - 2nd
	ed
Date: Thu, 4 Jun 2009 21:04:40 +0200
Message-ID: <cover.1244141444.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp14.tin.it ([212.216.176.118]:45541 "EHLO vsmtp14.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510AbZFDTEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 15:04:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches updated as requested. This time at least the day should be correct :-)

First patch is just cosmetic, to make easier to identify newer phys.
Second adds a new phy found on my Asus F5Sr laptop. It's an Atheros/Attansic
chip, but I wasn't able to identify it further.
The third patch should enable sis191 adapters to connect at Gb speeds
(at least, it does on my laptop). Also bumps the version number.
The gigabit check is a remix of SiS own GPL driver and forcedeth.

Riccardo Ghetta (3):
  sis190: better message on unknown PHY
  sis190: add new phy found on asus F5Sr laptop
  sis190: fix gigabit negotiation

 drivers/net/sis190.c |   53 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 18 deletions(-)

