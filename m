From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/2] qla3xxx: receive path bugfixes.
Date: Mon, 20 Aug 2007 13:32:09 -0700
Message-ID: <20070820203209.GB4181@linux-7mw0.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:46612 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759AbXHTUcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 16:32:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following two patches fix:

An undocumented "feature" where the 4032 chip sets bit-7
of the opcode for an inbound completion if it's for a VLAN.

The access of stale data on a completion entry.

These patches were built and tested on 2.6.23-rc1.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

