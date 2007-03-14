From: broonie@sirena.org.uk
Subject: [patch 0/3] natsemi updates
Date: Wed, 14 Mar 2007 19:49:12 +0000
Message-ID: <20070314194912.414925000@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, Tim Hockin <thockin@hockin.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:3934 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030883AbXCNUHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 16:07:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set contains a minor cleanup and two bug fixes for the
natsemi driver:

 1. Always use accessor functions for the interrupt enable register.
 2. Fix NAPI to work with shared interrupts.
 3. Ensure interrupts are not lost if the RX state machine locks up.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
