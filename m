From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 11:36:50 +0200
Message-ID: <cover.1273484094.git.marcel@holtmann.org>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53425 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab0EJJig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this is the big merge for the L2CAP Enhanced Retransmission support work
done by Gustavo F. Padovan. All other changes are small cleanups.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/btmrvl_drv.h   |    8 +-
 drivers/bluetooth/btmrvl_main.c  |   92 ++--
 drivers/bluetooth/btmrvl_sdio.c  |    7 +-
 drivers/bluetooth/hci_h4.c       |    2 +-
 drivers/bluetooth/hci_ll.c       |    8 +-
 drivers/bluetooth/hci_vhci.c     |    2 +-
 include/net/bluetooth/hci_core.h |    6 +-
 include/net/bluetooth/l2cap.h    |   41 +-
 net/bluetooth/Kconfig            |   13 +
 net/bluetooth/hci_core.c         |   27 +-
 net/bluetooth/hci_sysfs.c        |   34 +-
 net/bluetooth/l2cap.c            | 1108 +++++++++++++++++++++++++++++---------
 net/bluetooth/sco.c              |   26 +-
 13 files changed, 1010 insertions(+), 364 deletions(-)

through these ChangeSets:

Bing Zhao (3):
    Bluetooth: Decode btmrvl MODULE_BRINGUP_REG response correctly
    Bluetooth: Separate btmrvl_register_hdev() from btmrvl_add_card()
    Bluetooth: Set hdev->dev_type based on Marvell device type

Dan Carpenter (1):
    Bluetooth: Fix storing negative values as unsigned char

Gustavo F. Padovan (54):
    Bluetooth: Fix return value when bt_skb_alloc fails
    Bluetooth: Use the proper function cast to get hdr data
    Bluetooth: Fix wrong packet type count increment
    Bluetooth: Make hci_send_sco() void
    Bluetooth: Trivial clean ups to SCO
    Bluetooth: Move specific Basic Mode code to the right place
    Bluetooth: Fix memory leak of S-frames into L2CAP
    Bluetooth: Fix expected_tx_seq calculation on L2CAP
    Bluetooth: Fix ACL MTU issue
    Bluetooth: Use a l2cap_pinfo struct instead l2cap_pi() macro
    Bluetooth: Implement 'Send IorRRorRNR' event
    Bluetooth: Support case with F bit set under WAIT_F state.
    Bluetooth: Check the minimum {I,S}-frame size into L2CAP
    Bluetooth: Check if SDU size is greater than MTU on L2CAP
    Bluetooth: Implement SendAck() Action on ERTM.
    Bluetooth: Move set of P-bit to l2cap_send_sframe()
    Bluetooth: Add Recv RR (P=0)(F=0) for SREJ_SENT state on ERTM
    Bluetooth: Split l2cap_data_channel_sframe()
    Bluetooth: Handle all cases of receipt of RNR-frames into L2CAP
    Bluetooth: Group the ack of I-frames into l2cap_data_channel_rrframe()
    Bluetooth: Remove duplicate use of __get_reqseq() macro on L2CAP
    Bluetooth: Finish implementation for Rec RR (P=1) on ERTM
    Bluetooth: Add timer to Acknowledge I-frames
    Bluetooth: Ignore Tx Window value with Streaming mode
    Bluetooth: Read RFC conf option on a successful Conf RSP
    Bluetooth: Fix configuration of the MPS value
    Bluetooth: Add le16 macro to Retransmission and Monitor Timeouts values
    Bluetooth: Check the SDU size against the MTU value
    Bluetooth: Send Ack after clear the SREJ list
    Bluetooth: Add sockopt configuration for txWindow on L2CAP
    Bluetooth: Change acknowledgement to use the value of txWindow
    Bluetooth: Add module parameter for txWindow size on L2CAP
    Bluetooth: Enable option to configure Max Transmission value via
    Bluetooth: Fix bug when retransmitting I-frames
    Bluetooth: Fix crash when monitor timeout expires
    Bluetooth: Fix drop of acked packets on ERTM
    Bluetooth: Optimize SREJ_QUEUE append
    Bluetooth: Add Kconfig option for L2CAP Extended Features
    Bluetooth: Add SOCK_STREAM support to L2CAP
    Bluetooth: Fix SDU reassembly under SREJ
    Bluetooth: Don't set control bits to zero first
    Bluetooth: Fix errors reported by checkpatch.pl
    Bluetooth: Remove set of SrejSaveReqSeq under receipt of REJ frame
    Bluetooth: Remove unneeded control vars
    Bluetooth: Check if we really are in WAIT_F when F bit comes
    Bluetooth: Fix lockdep annotation on ERTM
    Bluetooth: Make hci_send_acl() void
    Bluetooth: Refactor l2cap_retransmit_frame()
    Bluetooth: Implement missing parts of the Invalid Frame Detection
    Bluetooth: Implement Local Busy Condition handling
    Bluetooth: Add wait_queue to wait ack of all sent packets
    Bluetooth: Fix race condition on l2cap_ertm_send()
    Bluetooth: Prevents buffer overflow on l2cap_ertm_reassembly_sdu()
    Bluetooth: Fix spec error in the RemoteBusy Logic

João Paulo Rechi Vita (3):
    Bluetooth: Check if mode is supported on getsockopt
    Bluetooth: Close L2CAP channel on invalid ReqSeq
    Bluetooth: Completes the I-frame tx_seq check logic on RECV

Marcel Holtmann (2):
    Bluetooth: Create per controller workqueue
    Bluetooth: Fix issues where sk_sleep() helper is needed now

Tomas Winkler (1):
    Bluetooth: Use strict_strtoul instead of simple_strtoul

