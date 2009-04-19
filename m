From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-04-19
Date: Sun, 19 Apr 2009 20:01:01 +0200
Message-ID: <1240164061.11795.66.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36449 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607AbZDSSBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 14:01:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here a three more patches for the 2.6.30 kernel release. The first one
adds a missing call to rfcomm_dlc_clear_timer. The other two are adding
workarounds for broken Bluetooth chips/firmware from Texas Instruments
and Broadcom. Without these two patches no audio connections can be
successfully established.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_event.c   |   38 +++++++++++++++++++++++++++-----------
 net/bluetooth/rfcomm/core.c |    2 ++
 2 files changed, 29 insertions(+), 11 deletions(-)

through these ChangeSets:

Johan Hedberg (1):
    Bluetooth: Fix removing of RFCOMM DLC timer with DEFER_SETUP

Marcel Holtmann (2):
    Bluetooth: Fallback from eSCO to SCO on unspecified error
    Bluetooth: Add workaround for wrong HCI event in eSCO setup



