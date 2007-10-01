From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/2] qla3xxx: receive path bugfixes.
Date: Mon, 1 Oct 2007 11:41:41 -0700
Message-ID: <20071001184141.GA22534@linux-7mw0.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:21575 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbXJASli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 14:41:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,
This is the second submission... First was in August. Thanks, Ron

The following two patches fix:

An undocumented "feature" where the 4032 chip sets bit-7
of the opcode for an inbound completion if it's for a VLAN.

The access of stale data on a completion entry.

These patches were built and tested on 2.6.23-rc1.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

