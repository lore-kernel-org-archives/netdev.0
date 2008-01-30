From: Roel Kluin <12o3l@tiscali.nl>
Subject: [drivers/net/bnx2.c] ADVERTISE_1000XPSE_ASYM
Date: Wed, 30 Jan 2008 15:07:44 +0100
Message-ID: <47A084B0.1000301@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:49045 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761301AbYA3OHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 09:07:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In drivers/net/bnx2.c:1285: it reads in function bnx2_setup_remote_phy():

if (pause_adv & (ADVERTISE_1000XPSE_ASYM | ADVERTISE_1000XPSE_ASYM))

Note that the two are the same and this is therefore equivalent to

if (pause_adv & ADVERTISE_1000XPSE_ASYM)

This appears to be incorrect, was maybe '| ADVERTISE_1000XPAUSE' intended?
