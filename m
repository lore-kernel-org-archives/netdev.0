From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.27 merge window
Date: Thu, 17 Jul 2008 12:00:48 +0200
Message-ID: <1216288848.22564.5.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44843 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbYGQKAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are the Bluetooth core updates for 2.6.27 kernel release. The
majority of changes is to support the Simple Pairing that has been
introduced with the Bluetooth 2.1 specification. Even older devices
benefit from these security enhancements.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 fs/compat_ioctl.c                 |    1 +
 include/net/bluetooth/bluetooth.h |    1 +
 include/net/bluetooth/hci.h       |   68 +++++-
 include/net/bluetooth/hci_core.h  |   19 +-
 include/net/bluetooth/rfcomm.h    |    2 +
 net/bluetooth/af_bluetooth.c      |   53 ++++-
 net/bluetooth/bnep/core.c         |    5 +
 net/bluetooth/hci_conn.c          |   96 ++++++--
 net/bluetooth/hci_core.c          |   42 ++-
 net/bluetooth/hci_event.c         |  512 ++++++++++++++++++++++++++++++++-----
 net/bluetooth/hci_sock.c          |   18 +-
 net/bluetooth/hci_sysfs.c         |   31 ++-
 net/bluetooth/hidp/core.c         |   10 +
 net/bluetooth/l2cap.c             |  337 +++++++++++++++++--------
 net/bluetooth/rfcomm/core.c       |   92 +++++---
 net/bluetooth/rfcomm/sock.c       |   23 ++-
 net/bluetooth/rfcomm/tty.c        |   59 +++++-
 net/bluetooth/sco.c               |   14 +-
 18 files changed, 1112 insertions(+), 271 deletions(-)

through these ChangeSets:

Marcel Holtmann (26):
    [Bluetooth] Change retrieval of L2CAP features mask
    [Bluetooth] Enforce security for outgoing RFCOMM connections
    [Bluetooth] Disconnect when encryption gets disabled
    [Bluetooth] Update authentication status after successful encryption
    [Bluetooth] Support the case when headset falls back to SCO link
    [Bluetooth] Track connection packet type changes
    [Bluetooth] Make use of the default link policy settings
    [Bluetooth] Some cleanups for HCI event handling
    [Bluetooth] Update class of device value whenever possible
    [Bluetooth] Disable disconnect timer during Simple Pairing
    [Bluetooth] Track status of Simple Pairing mode
    [Bluetooth] Track status of remote Simple Pairing mode
    [Bluetooth] Export remote Simple Pairing mode via sysfs
    [Bluetooth] Use ACL config stage to retrieve remote features
    [Bluetooth] Initiate authentication during connection establishment
    [Bluetooth] Export details about authentication requirements
    [Bluetooth] Add timestamp support to L2CAP, RFCOMM and SCO
    [Bluetooth] Add support for TIOCOUTQ and TIOCINQ ioctls
    [Bluetooth] Use a more unique bus name for connections
    [Bluetooth] Update Bluetooth core version number
    [Bluetooth] Use non-canonical TTY by default for RFCOMM
    [Bluetooth] Store remote modem status for RFCOMM TTY
    [Bluetooth] Move pending packets from RFCOMM socket to TTY
    [Bluetooth] Signal user-space for HIDP and BNEP socket errors
    [Bluetooth] Add option to disable eSCO connection creation
    [Bluetooth] Allow security for outgoing L2CAP connections



