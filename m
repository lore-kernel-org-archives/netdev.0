From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 0/3] sis190 gigabit fixes(bug 9735,11149) and new phy
Date: Wed, 3 Jun 2009 10:49:01 +0200
Message-ID: <cover.1244012631.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp21.tin.it ([212.216.176.109]:56103 "EHLO vsmtp21.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184AbZFBIxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:53:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch add a new phy found on my Asus F5Sr laptop. I suppose 
it's an Atheros chip, but really don't know.
The second patch should enable sis191 adapters to connect at Gb speeds
(at least, it does on my laptop). Also bumps the version number.
The third is just cosmetic, to make easier to identify newer phys.

Riccardo Ghetta (3):
  sis190: add new phy found on asus F5 series laptops
  sis190: fix gigabit negotiation
  sis190: better message on unknown PHY

 drivers/net/sis190.c |   53 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 18 deletions(-)

