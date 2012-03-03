From: Gustavo Padovan <padovan@profusion.mobi>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Sat, 3 Mar 2012 13:46:55 -0300
Message-ID: <20120303164655.GA5275@joana>
References: <20120301.222316.1877216960521396397.davem@davemloft.net>
 <20120301.222604.1508242694024394849.davem@davemloft.net>
 <20120302163716.GA18758@joana>
 <20120302.161501.1891197361615438878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gustavo@padovan.org, johan.hedberg@gmail.com,
	linville@tuxdriver.com, marcel@holtmann.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57764 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab2CCQrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 11:47:18 -0500
Received: by ghrr11 with SMTP id r11so1215469ghr.19
        for <netdev@vger.kernel.org>; Sat, 03 Mar 2012 08:47:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20120302.161501.1891197361615438878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

* David Miller <davem@davemloft.net> [2012-03-02 16:15:01 -0500]:

> From: Gustavo Padovan <padovan@profusion.mobi>
> Date: Fri, 2 Mar 2012 13:37:16 -0300
> 
> > are you telling me to make a patch to fix this issue in the whole
> > Bluetooth subsystem
> 
> I'm saying get it right in new code changes.

This is something we can't do. Changing only the new code will put the
Bluetooth subsystem in a inconsistent coding style with different styles
through the subsystem.

Also I talked with Marcel and Johan about this, we think the most important
here is to have this code in the 3.4 release and taking in account that this
coding style is the same we've been using for the last 11 years we think this
style discussion is not really important compared to the need to have our
changes in 3.4.

So our current idea here is keep this pull request and ask you to pull it as
is. If it happens that this doesn't get pulled into mainline for 3.4 then we
will have to deal with a worst problem that is keep our tree out of mainline.

	Gustavo


The following changes since commit b4017c5368f992fb8fb3a2545a0977082c6664e4:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-03-01 17:57:40 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-next.git master

Andre Guedes (24):
      Bluetooth: Add 'eir_len' param to mgmt_device_found()
      Bluetooth: Report LE devices
      Bluetooth: Use GFP_KERNEL in hci_conn_add()
      Bluetooth: Use GFP_KERNEL in hci_chan_create()
      Bluetooth: Fix potential deadlock
      Bluetooth: Remove unneeded locking
      Bluetooth: Use GFP_KERNEL in hci_add_adv_entry()
      Bluetooth: LE scan should send Discovering events
      Bluetooth: Minor code refactoring
      Bluetooth: Add hci_do_le_scan()
      Bluetooth: Add hci_le_scan()
      Bluetooth: MGMT start discovery LE-Only support
      Bluetooth: Fix indentation
      Bluetooth: Add BT_DBG to mgmt_discovering()
      Bluetooth: Fix discovery state machine
      Bluetooth: Fix event sending with DISCOVERY_STOPPED state
      Bluetooth: Prepare start_discovery
      Bluetooth: Track discovery type
      Bluetooth: Merge INQUIRY and LE_SCAN discovery states
      Bluetooth: Interleaved discovery support
      Bluetooth: Set DISCOVERY_STOPPED if controller resets
      Bluetooth: Change interleaved discovery behavior
      Bluetooth: Fix Kconfig help description
      Bluetooth: Check capabilities in BR/EDR and LE-Only discovery

Andrei Emeltchenko (30):
      Bluetooth: Process num completed data blocks event
      Bluetooth: Remove magic number from ACL TO
      Bluetooth: Use chan instead of sk
      Bluetooth: Change sk to l2cap_chan
      Bluetooth: trivial: space correction
      Bluetooth: Add alloc_skb chan operator
      Bluetooth: Use list _safe deleting from conn_hash_list
      Bluetooth: Use list _safe deleting from conn chan_list
      Bluetooth: Recalculate sched HCI blk/pkt flow ctrl
      Bluetooth: Helper removes duplicated code
      Bluetooth: Change chan_ready param from sk to chan
      Bluetooth: Clean up l2cap_chan_add
      Bluetooth: Remove unneeded sk variable
      Bluetooth: Do not dereference zero sk
      Bluetooth: Move scope of state_to_string
      Bluetooth: Use symbolic names for state in debug
      Bluetooth: Prefix hex numbers with object name
      Bluetooth: trivial: Fix long line
      Bluetooth: Revert to mutexes from RCU list
      Bluetooth: Add l2cap_chan_lock
      Bluetooth: Add locked and unlocked state_change
      Bluetooth: Add socket error function
      Bluetooth: Fix coding style issues in mgmt code
      Bluetooth: Add unlocked __l2cap_chan_add function
      Bluetooth: Change sk lock to chan lock in L2CAP core
      Bluetooth: Remove socket lock check
      Bluetooth: Fix init request completion with AMP controllers
      Bluetooth: Fix double locking in LE and conless chan
      Bluetooth: Remove duplicated code in l2cap conn req
      Bluetooth: Save remote L2CAP fixed channel mask

Andrzej Kaczmarek (2):
      Bluetooth: Fix sk_sndtimeo initialization for L2CAP socket
      Bluetooth: l2cap_set_timer needs jiffies as timeout value

Dan Carpenter (2):
      Bluetooth: use kfree_skb() instead of kfree()
      Bluetooth: change min_t() cast in hci_reassembly()

Daniel Wagner (1):
      Bluetooth: Don't mark non xfer isoc endpoint URBs with URB_ISO_ASAP

David Herrmann (28):
      Bluetooth: hci-uart-ll: Use GFP_ATOMIC in open()
      Bluetooth: hci-uart-h4: Use GFP_ATOMIC in open()
      Bluetooth: hci-uart-bcsp: Use GFP_ATOMIC in open()
      Bluetooth: hci-uart-ath: Use GFP_ATOMIC in open()
      Bluetooth: dtl1: Fix memleak in probe()
      Bluetooth: Make hci-destruct callback optional
      Bluetooth: bluecard-cs: Remove empty destruct cb
      Bluetooth: bt3c-cs: Remove empty destruct cb
      Bluetooth: btmrvl: Remove empty destruct cb
      Bluetooth: btuart-cs: Remove empty destruct cb
      Bluetooth: btwilink: Remove empty destruct cb
      Bluetooth: dtl1-cs: Remove empty destruct cb
      Bluetooth: vhci: Free driver_data on file release
      Bluetooth: bfusb: Free driver_data on USB shutdown
      Bluetooth: btusb: Free driver data on USB shutdown
      Bluetooth: bpa10x: Free private driver data on usb shutdown
      Bluetooth: btsdio: Free driver data on SDIO shutdown
      Bluetooth: uart-ldisc: Fix memory leak and remove destruct cb
      Bluetooth: Remove unused hci-destruct cb
      Bluetooth: Correctly acquire module ref
      Bluetooth: Remove HCI-owner field
      Bluetooth: Correctly take hci_dev->dev refcount
      Bluetooth: Remove __hci_dev_put/hold
      Bluetooth: Introduce to_hci_dev()
      Bluetooth: Remove hci_dev->driver_data
      Bluetooth: Introduce to_hci_conn
      Bluetooth: Use proper datatypes in release-callbacks
      Bluetooth: btusb: Remove device lock on release

Fabio Estevam (1):
      Bluetooth: Fix 'enable_hs' type

Gustavo F. Padovan (1):
      Bluetooth: Fix coding style with breaking lines

Hemant Gupta (2):
      Bluetooth: Send correct response to IO Capability Request
      Bluetooth: Fix clearing of debug and linkkey flags

Joe Perches (1):
      Bluetooth: Add logging functions bt_info and bt_err

Johan Hedberg (119):
      Bluetooth: Convert inquiry cache to use standard list types
      Bluetooth: Move Extended Inquiry Response defines to hci.h
      Bluetooth: Add initial mgmt_confirm_name support
      Bluetooth: Return updated name state with hci_inquiry_cache_update
      Bluetooth: Flush inquiry cache when starting mgmt triggered inquiry
      Bluetooth: Rename hdev->inq_cache to hdev->discovery
      Bluetooth: Add discovery state tracking
      Bluetooth: Add name resolving support for mgmt based discovery
      Bluetooth: Remove bogus inline declaration from l2cap_chan_connect
      Bluetooth: Move mgmt related flags from hdev->flags to hdev->dev_flags
      Bluetooth: Fix resetting HCI_MGMT flag
      Bluetooth: Sort to-be-resolved devices by RSSI during discovery
      Bluetooth: Fix clearing persistent flags
      Bluetooth: Rename mgmt connected events to match user space
      Bluetooth: Add eir_len parameter to mgmt_ev_device_found
      Bluetooth: Rename eir_has_complete_name to eir_has_data_type
      Bluetooth: Add missing EIR defines to hci.h
      Bluetooth: Move eir_has_data_field to hci_core.h
      Bluetooth: Merge device class into the EIR data in mgmt_ev_device_found
      Bluetooth: Rename conn->pend to conn->flags
      Bluetooth: Convert hdev->out to a bool type
      Bluetooth: Update device_connected and device_found events to latest API
      Bluetooth: Merge boolean members of struct hci_conn into flags
      Bluetooth: Convert hdev->ssp_mode to a flag
      Bluetooth: Add a convenience function to check for SSP enabled
      Bluetooth: Update mgmt.h to match latest API spec
      Bluetooth: mgmt: Implement Cancel Pair Device command
      Bluetooth: Add missing QUIRK_NO_RESET test to hci_dev_do_close
      Bluetooth: Fix device_found event length for remote name resolving
      Bluetooth: Update and rename mgmt_remove_keys to mgmt_unpair_device
      Bluetooth: Update mgmt_disconnect to match latest API
      Bluetooth: Add address type to user_confirm and user_passkey messages
      Bluetooth: Add address type to Out Of Band mgmt messages
      Bluetooth: Add address type to mgmt blacklist messages
      Bluetooth: Add address type to mgmt_ev_auth_failed
      Bluetooth: Fix mgmt_unpair_device command status
      Bluetooth: Add Device Unpaired mgmt event
      Bluetooth: Implement Read Supported Commands commands for mgmt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next.git
      Bluetooth: Remove unused member from cmd_lookup struct
      Bluetooth: mgmt: Use more consistent error variable names
      Bluetooth: mgmt: Add support for Set Link Security command
      Bluetooth: mgmt: Add support for Set SSP command
      Bluetooth: mgmt: Add address type to link key messages
      Bluetooth: mgmt: Add address type to PIN code messages
      Bluetooth: mgmt: Add address type to confirm name command
      Bluetooth: Add Intel copyright to mgmt files
      Bluetooth: mgmt: Change ordering of cmd_status paramters
      Bluetooth: mgmt: Move status parameters into the cmd_complete header
      Bluetooth: mgmt: Fix Pair Device response status values
      Bluetooth: mgmt: Fix Start Discovery return parameters
      Bluetooth: mgmt: Fix (Un)Block Device return parameters
      Bluetooth: mgmt: Fix OOB command response parameters
      Bluetooth: mgmt: Bump mgmt version
      Bluetooth: Fix hci_connect error return values
      Bluetooth: mgmt: Add address type parameter to Stop Discovery command
      Bluetooth: mgmt: Add address type parameter to Discovering event
      Bluetooth: mgmt: Add basic support for Set High Speed command
      Bluetooth: mgmt: Fix Set SSP check for supported feature
      Bluetooth: mgmt: Clear EIR data when disabling SSP
      Bluetooth: mgmt: Fix powered checks for commands
      Bluetooth: mgmt: Fix set_local_name and set_dev_class powered checks
      Bluetooth: mgmt: Fix set_fast_connectable error return
      Bluetooth: mgmt: Fix pairable setting upon initialization
      Bluetooth: mgmt: Allow connectable/discoverable changes in off state
      Bluetooth: mgmt: Fix Removing discoverable timeout in set_connectable
      Bluetooth: mgmt: Fix current settings values when powered off
      Bluetooth: mgmt: Add convenience function for sending New Settings
      Bluetooth: mgmt: Fix New Settings event for connectable/discoverable
      Bluetooth: Fix clearing of persistent dev_flags
      Bluetooth: mgmt: Fix connectable/discoverable response values
      Bluetooth: mgmt: Make Set Link Security callable while powered off
      Bluetooth: Remove unneeded hci_cc_read_ssp_mode function
      Bluetooth: mgmt: Make Set SSP command callable while powered off
      Bluetooth: mgmt: Fix EIR toggling with SSP
      Bluetooth: mgmt: Fix clearing of hdev->eir
      Bluetooth: Explicitly clear EIR data upon hci_dev setup
      Bluetooth: mgmt: Fix Set SSP supported check
      Bluetooth: mgmt: Implement Set LE command
      Bluetooth: Fix EIR data clearing when powering off
      Bluetooth: mgmt: Fix updating EIR when updating the name
      Bluetooth: Add hdev->short_name for EIR generation
      Bluetooth: Fix read_name updating when HCI_SETUP is not set
      Bluetooth: mgmt: Allow local name changes while powered off
      Bluetooth: mgmt: Fix name_changed event for short name changes
      Bluetooth: mgmt: Fix missing short_name in read_info
      Bluetooth: Fix clearing of dev_class when powering down
      Bluetooth: mgmt: Fix return value for set_class
      Bluetooth: mgmt: Check for HCI_UP in update_eir() and update_class()
      Bluetooth: mgmt: Allow class of device changes while powered off
      Bluetooth: mgmt: Add missing powered checks to commands
      Bluetooth: mgmt: Fix unpair_device responses
      Bluetooth: mgmt: Fix device_found parameters
      Bluetooth: mgmt: Add legacy pairing info to dev_found events
      Bluetooth: mgmt: Fix count parameter in get_connections reply
      Bluetooth: mgmt: Fix update_eir/class with HCI_AUTO_OFF flag set
      Bluetooth: mgmt: Fix return value of add/remove_uuid
      Bluetooth: mgmt: Move service cache setting to a more sensible place
      Bluetooth: mgmt: Fix clear UUIDs response
      Bluetooth: mgmt: Add flags parameter to device_connected
      Bluetooth: mgmt: Track pending class changes
      Bluetooth: mgmt: Fix dev_class related command response timing
      Bluetooth: mgmt: Fix clear_uuids response
      Bluetooth: Fix init request completion with old controllers
      Bluetooth: Use kernel int types instead of ones from stdint.h
      Bluetooth: Don't send unnecessary write_le_enable command
      Bluetooth: Remove redundant read_host_features commands
      Bluetooth: Add missing host features definitions
      Bluetooth: Use LMP_HOST_SSP define instead of magic values
      Bluetooth: mgmt: Add missing hci_dev locking to set_le()
      Bluetooth: Fix init sequence for some CSR based controllers
      Bluetooth: mgmt: Refactor hci_dev lookup for commands
      Bluetooth: mgmt: Initialize HCI_MGMT flag for any command
      Bluetooth: mgmt: Move command handlers into a table
      Bluetooth: mgmt: Add defines for command sizes
      Bluetooth: mgmt: Centralize message length checks
      Bluetooth: Fix clearing of HCI_PENDING_CLASS flag
      Bluetooth: mgmt: Fix command status error code values
      Bluetooth: mgmt: Add new error code for invalid index

Keng-Yu Lin (1):
      Bluetooth: Add AR30XX device ID on Asus laptops

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c 21f3) for BCM20702A0

Marcel Holtmann (25):
      Bluetooth: Split sending for HCI raw and control sockets
      Bluetooth: Remove unneeded bt_cb(skb)->channel variable
      Bluetooth: Limit HCI raw socket options to actual raw sockets
      Bluetooth: Lock socket when reading HCI socket options
      Bluetooth: Add HCI CMSG details only to raw sockets
      Bluetooth: Simplify HCI socket bind handling
      Bluetooth: Fix issue with shared SKB between HCI raw socket and driver
      Bluetooth: Remove HCI notifier handling
      Bluetooth: Add support for HCI monitor channel
      Bluetooth: Restrict access to management interface
      Bluetooth: Set supported settings based on enabled HS and/or LE
      Bluetooth: Always enable management interface
      Bluetooth: Fix parameter list for setting local name
      Bluetooth: Only keep controller up after init if powered on
      Bluetooth: Don't send New Settings event during setup power down
      Bluetooth: Fix two minor style issues in management code
      Bluetooth: Fix two minor style issues in HCI code
      Bluetooth: Enable timestamps for control channel
      Bluetooth: Disabling discoverable with timeout is invalid
      Bluetooth: Fix handling of discoverable setting with timeout
      Bluetooth: Send management event for class of device changes
      Bluetooth: Allow HCI UART reset parameter via flags ioctl
      Bluetooth: Add support for creating HCI UART based AMP controllers
      Bluetooth: Update L2CAP timeout constants to use msecs_to_jiffies
      Bluetooth: Update MGMT and SMP timeout constants to use msecs_to_jiffies

Octavian Purdila (2):
      Bluetooth: silence lockdep warning
      Bluetooth: Fix RFCOMM session reference counting issue

Peter Hurley (1):
      Bluetooth: Fix l2cap conn failures for ssp devices

Szymon Janc (9):
      Bluetooth: Make l2cap_clear_timer return if timer was running or not
      Bluetooth: Set P-bit for SREJ frame only if there are I-frames to ack
      Bluetooth: Clear ack_timer when sending ack
      Bluetooth: Don't send RNR immediately when entering local busy
      Bluetooth: Drop L2CAP chan reference if ERTM ack_timer fired
      Bluetooth: Make l2cap_ertm_data_rcv static
      Bluetooth: Fix possible missing I-Frame acknowledgement
      Bluetooth: Fix double acking I-Frames when sending pending I-Frames
      Bluetooth: Use NULL instead of integer for mgmt_device_connected param

Ulisses Furquim (2):
      Bluetooth: Remove usage of __cancel_delayed_work()
      Bluetooth: Fix possible use after free in delete path

Vinicius Costa Gomes (11):
      Bluetooth: Fix using an absolute timeout on hci_conn_put()
      Bluetooth: Add structures for the new LTK exchange messages
      Bluetooth: Rename smp_key_size to enc_key_size
      Bluetooth: Fix invalid memory access when there's no SMP channel
      Bluetooth: Fix doing some useless casts when receiving MGMT commands
      Bluetooth: Add new structures for handling SMP Long Term Keys
      Bluetooth: Use the updated key structures for handling LTKs
      Bluetooth: Add MGMT handlers for dealing with SMP LTK's
      Bluetooth: Add support for removing LTK's when pairing is removed
      Bluetooth: Clean up structures left unused
      Bluetooth: Add support for notifying userspace of new LTK's

 drivers/bluetooth/ath3k.c          |    1 +
 drivers/bluetooth/bfusb.c          |   23 +-
 drivers/bluetooth/bluecard_cs.c    |   20 +-
 drivers/bluetooth/bpa10x.c         |   35 +-
 drivers/bluetooth/bt3c_cs.c        |   14 +-
 drivers/bluetooth/btmrvl_debugfs.c |   27 +-
 drivers/bluetooth/btmrvl_main.c    |   17 +-
 drivers/bluetooth/btsdio.c         |   23 +-
 drivers/bluetooth/btuart_cs.c      |   14 +-
 drivers/bluetooth/btusb.c          |   47 +-
 drivers/bluetooth/btwilink.c       |   18 +-
 drivers/bluetooth/dtl1_cs.c        |   34 +-
 drivers/bluetooth/hci_ath.c        |    2 +-
 drivers/bluetooth/hci_bcsp.c       |    2 +-
 drivers/bluetooth/hci_h4.c         |    2 +-
 drivers/bluetooth/hci_ldisc.c      |   34 +-
 drivers/bluetooth/hci_ll.c         |    2 +-
 drivers/bluetooth/hci_uart.h       |    2 +
 drivers/bluetooth/hci_vhci.c       |   17 +-
 include/net/bluetooth/bluetooth.h  |   40 +-
 include/net/bluetooth/hci.h        |   72 +-
 include/net/bluetooth/hci_core.h   |  284 +++--
 include/net/bluetooth/hci_mon.h    |   51 +
 include/net/bluetooth/l2cap.h      |   37 +-
 include/net/bluetooth/mgmt.h       |  231 +++--
 include/net/bluetooth/smp.h        |    2 +-
 net/bluetooth/Kconfig              |    1 -
 net/bluetooth/bnep/sock.c          |    6 +-
 net/bluetooth/cmtp/sock.c          |    6 +-
 net/bluetooth/hci_conn.c           |   73 +-
 net/bluetooth/hci_core.c           |  627 +++++++--
 net/bluetooth/hci_event.c          |  607 ++++++---
 net/bluetooth/hci_sock.c           |  470 ++++++--
 net/bluetooth/hci_sysfs.c          |   53 +-
 net/bluetooth/hidp/sock.c          |    6 +-
 net/bluetooth/l2cap_core.c         |  638 +++++----
 net/bluetooth/l2cap_sock.c         |   53 +-
 net/bluetooth/lib.c                |   27 +-
 net/bluetooth/mgmt.c               | 2590 +++++++++++++++++++++++-------------
 net/bluetooth/smp.c                |   92 +-
 40 files changed, 4157 insertions(+), 2143 deletions(-)
 create mode 100644 include/net/bluetooth/hci_mon.h
