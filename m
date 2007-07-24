From: bphilips@suse.de
Subject: [PATCH 0/2][RFC] Update network drivers to use devres
Date: Tue, 24 Jul 2007 15:39:51 -0700
Message-ID: <11853167931415-git-send-email-bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39227 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbXGXWj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:39:57 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id B726D21951
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 00:39:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches update the network driver core and the e100 driver to use devres.
Devres is a simple resource manager for device drivers, see
Documentation/driver-model/devres.txt for more information.

If the RFC goes well I will create patches to update all applicable network
drivers.

Applies against 2.6.22

