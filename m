From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for 2.6.25
Date: Fri, 18 Jan 2008 15:17:21 -0500
Message-ID: <20080118201721.GA22699@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56370 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757679AbYARURW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 15:17:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from the 'upstream' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git up=
stream

to receive my 2.6.25 net driver queue into davem/net-2.6.25.git:

Adam Baker (2):
      rt2x00: Unconstify rt2x00dev
      rt2x00: Place mutex around USB register access

Adrian Bunk (4):
      drivers/net/netxen/: cleanups
      drivers/net/chelsio/: #if 0 unused functions
      ipg: add __devexit annotation
      e1000: remove no longer used code for pci read/write cfg

Al Viro (15):
      endianness annotations and fixes for olympic
      sunhme endianness annotations
      sungem endianness annotations=1B
      e1000e endianness annotations
      e1000 endianness annotations
      NULL noise in drivers/net
      forcedeth endianness bugs
      e100 endianness annotations
      ixgbe endianness annotations
      ixgb endianness annotations
      annotate tun
      annotate the rest of drivers/net/wan
      eepro100 annotations
      slhc annotations
      qla3xxx annotations

Alan Cox (2):
      3c501: Bring into compliance with the coding style
      slip: Drag kicking and screaming into coding style compliance

Alejandro Martinez Ruiz (3):
      netdev: use ARRAY_SIZE() instead of sizeof(array) / ETH_GSTRING_L=
EN
      netdev: ARRAY_SIZE() cleanups
      sk98lin: kill bogus check and convert to use ARRAY_SIZE()

Andrea Merello (1):
      rtl8187: fix tx power reading

Andres Salomon (4):
      libertas: drop useless default_fw_name variable
      libertas: mark module_init/exit functions as __init/__exit
      libertas: reset devices upon disconnect rather than module unload=
ing
      libertas: nuke useless variable usbdriver_name and useless commen=
ts

Auke Kok (6):
      e1000e: Disable L1 ASPM power savings for 82573 mobile variants
      e1000/e1000e: Move PCI-Express device IDs over to e1000e
      ixgbe: Fix copper PHY initialization code
      [E1000E]: update netstats traffic counters realtime
      [E1000]: update netstats traffic counters realtime
      e1000: Dump the eeprom when a user encounters a bad checksum

Ben M Cahill (29):
      iwl3945: re-align 3945 event log data
      iwl4965: add comments to rate scaling code
      iwlwifi: add comments to EEPROM stuff
      iwl-4965-hw.h: clean up unused eeprom structures and definitions
      iwlwifi: clean up and clarify some comments after 3945/4965 split
      iwlwifi: Move is_legacy() macro family from iwl-4965-hw.h to iwl-=
4965-rs.h
      iwlwifi: Add comments to some driver data structures
      iwlwifi: Document 4965 rate_n_flags bits
      iwlwifi: Document Rx calibration
      iwlwifi: Partially clean-up, add comments to iwl-*-hw.h
      iwlwifi: clean up some unused definitions in iwl-4965.h and iwl-3=
945.h
      iwlwifi: add comments, mostly on Tx queues
      iwlwifi: add comments to iwl*-base.c
      iwlwifi: Clean up unused definitions in iwl-3945-hw.h
      iwlwifi: clean up unused definitions in iwl-4965-hw.h
      iwlwifi: move uCode API definitions to iwl-4965-commands.h
      iwlwifi: move HT_IE_EXT_CHANNEL_* driver definitions to iwl-4965.=
h
      iwlwifi: document temperature calculation
      iwlwifi: document txpower calculations
      iwlwifi: document keep-warm buffer
      iwlwifi: document Rx registers
      iwlwifi: document Tx registers
      iwlwifi: document shared Tx structures
      iwlwifi: document 4965 Tx scheduler
      iwlwifi: document command header and "alive" responses
      iwlwifi: add comments to RXON command and txpower formats
      iwlwifi: add comments to QOS and ADD_STA commands
      iwlwifi: add comments to Tx commands
      iwlwifi: document 4965 rate scaling

Bill Hayes (1):
      e1000e: alternate MAC address support

Brajesh Dave (2):
      libertas: separate mesh connectivity from that of the main interf=
ace
      libertas: configurable beacon interval

Christoph Hellwig (4):
      iwlwifi: mark more functions/variables static
      iwlwifi: keep 3945 and 4965 headers separate
      iwlwifi: cleanup Kconfig and ifdefs to split 3945 and 4965
      iwlwifi: cleanup namespace

Claudio Lanconelli (1):
      add driver for enc28j60 ethernet chip

Dan Williams (12):
      orinoco: more reliable scan handling
      orinoco: always use latest BSS info when caching scan results
      libertas: make lbs_cmd() usage nicer
      libertas: clean up is_command_allowed_in_ps()
      libertas: clean up direct command handling
      libertas: add simple copyback command callback
      libertas: convert GET_HW_SPEC to a direct command
      libertas: rename and re-type bufvirtualaddr to cmdbuf
      libertas: fix case of FWT_ACCESS_LIST_ROUTE and FWT_ACCESS_LIST_N=
EIGHBOR commands
      libertas: convert DATA_RATE to a direct command
      libertas: convert RF_CHANNEL to a direct command
      libertas: endianness fixes for get_channel/set_channel

Daniel Drake (3):
      zd1211rw: port to mac80211
      zd1211rw: Add ID for Trendnet TEW-429UB A
      zd1211rw: add copyright notices

David Acker (1):
      Fix e100 on systems that have cache incoherent DMA

David Miller (1):
      NET: ns83820.c remove fastcall macro

David Woodhouse (114):
      libertas: Fix memory leak of RX skbs
      libertas: Remove cmd_oid from struct cmd_ctrl_node
      libertas: Consolidate lbs_host_to_card_done() function.
      libertas: Don't claim to have checksummed incoming packets.
      libertas: Move SET_BOOT2_VER command to if_usb where it belongs
      libertas: Zero 'pdata_size' field in cmd_ctrl_node reliably.
      libertas: Byteswap cmdptr->size in lbs_cmd()
      libertas: Use lbs_cmd() for setting Boot2 version
      libertas: Remove SET_BOOT2_VER support from the Big Switch Statem=
ent.
      libertas: Fix endianness in boot2_version handling.
      libertas: when usb_submit_usb fails, include the error code in th=
e printk
      libertas: Switch to using a callback function pointer for command=
s
      libertas: Don't set IW_ENCODE_NOKEY when returning WEP keys.
      libertas: Fix up error handling in lbs_setuserscan()
      libertas: kill adapter->nr_cmd_pending
      libertas: switch lbs_cmd() to take a callback function pointer
      libertas: clean up lbs_thread() to make it slightly more readable
      libertas: fix lbs_rtap attribute in sysfs
      libertas: kill TxLockFlag
      libertas: kill struct lbs_adapter
      libertas: use lbs_host_to_card_done() in lbs_tx_timeout()
      libertas: cope with device which already has firmware loaded
      libertas: stop debugfs code looking at cmdpendingq
      libertas: kill internal tx queue for PS mode
      libertas: kill SendSinglePacket() function.
      libertas: move lbs_hard_start_xmit() into tx.c
      libertas: kill lbs_process_tx() by merging it into lbs_hard_start=
_xmit()
      libertas: clean up lbs_hard_start_xmit()
      libertas: kill lbs_pre_start_xmit(), lib_mesh_pre_start_xmit()
      libertas: stop using ieee80211 for radiotap device
      libertas: set dev_addr on rtap device
      libertas: TX packet is radiotap iff it comes from rtap_dev
      libertas: free successfully transmitted skbs again
      libertas: refactor the 'should I sleep?' decision in lbs_thread()
      libertas: Move actual transmission to main thread
      libertas: remove unreachable code from process_rxed_802_11_packet=
()
      libertas: fix error cases in lbs_process_rxed_802_11_packet()
      libertas: kill lbs_upload_tx_packet()
      libertas: kill (IS,SET,UNSET)_MESH_FRAME.
      libertas: add opaque extra argument to cmd callback function
      libertas: clean up lbs_interrupt()
      libertas: remove pre_open_check()
      libertas: make rtap and normal modes mutually exclusive, clean up=
 open/stop
      libertas: improve reliability of firmware reloading on USB
      libertas: switch to a waitqueue and timer for handling USB firmwa=
re load
      libertas: don't run thread while firmware not yet ready
      libertas: switch USB cardp->priv to 'struct lbs_private *' and re=
sulting fix
      libertas: move removal of lbs_rtap file to lbs_stop_card()
      libertas: wait for 'firmware ready' event from firmware after loa=
ding
      libertas: fix debug output in lbs_cmd_copyback() function.
      libertas: convert CMD_MESH_ACCESS to a direct command
      libertas: remove casts from lbs_cmd() and lbs_cmd_with_response()=
 macros
      libertas: make some more functions static
      libertas: fix sparse endianness warnings in scan.c
      libertas: add lbs_mesh sysfs attribute for enabling mesh
      libertas: kill references to mesh autostart
      libertas: kill rx_urb_recall and eth_dev members of struct usb_ca=
rd_rec
      libertas: whitespace cleanup in host.h
      libertas: allow get/set SSID on mshX device
      libertas: allow setting channel on mshX device
      libertas: add missing newline on debug message
      libertas: disable mesh temporarily while setting eth channel/asso=
c
      libertas: add debugging output to lbs_mesh_config()
      libertas: be more careful about command responses matching cur_cm=
d
      libertas: add missing newlines in debugging statements
      libertas: slight cleanup of netif queue stop/wake
      libertas: add lbs_host_sleep_cfg() command function
      libertas: switch lbs_cmd() to take a _pointer_ to the command str=
ucture
      libertas: make worker thread not freezable
      libertas: implement suspend and resume core methods
      libertas: implement suspend/resume for USB devices
      libertas: add ethtool support for wake-on-lan configuration
      libertas: make lbs_update_channel() function non-static
      libertas: cope with both old and new mesh TLV values
      libertas: pass channel argument directly to lbs_mesh_config()
      libertas: use spin_is_locked() instead of spin_trylock() in lbs_i=
nterrupt()
      libertas: don't exit worker thread until kthread_stop() is called
      libertas: stop attempting to reset devices on unload
      libertas: clean up if_usb driver
      libertas: kill whitespace at end of lines
      libertas: kill unused wait_option field in struct cmd_ctrl_node
      libertas: rename and clean up DownloadcommandToStation
      libertas: don't use __lbs_cmd() with empty callback in if_usb.c
      libertas: remove some pointless checks for cmdnode buffer being p=
resent
      libertas: introduce and use lbs_complete_command() for command co=
mpletion
      libertas: don't re-initialise cmdnode when taking it off the free=
 queue
      libertas: kill cleanup_cmdnode()
      libertas: let __lbs_cmd() free its own cmdnode
      libertas: kill pdata_buf member of struct cmd_ctrl_node
      libertas: store command result in cmdnode instead of priv->cur_cm=
d_retcode
      libertas: add __lbs_cmd_async() for asynchronous command submissi=
on
      libertas: ensure response buffer size is always set for lbs_cmd_w=
ith_response
      libertas: handle command timeout in main thread instead of direct=
ly in timer
      libertas: kill 'addtail' argument to lbs_queue_cmd() and make it =
static
      libertas: fix return from lbs_update_channel()
      libertas: add SLEEP_PERIOD and FW_WAKE_METHOD command definitions
      libertas: fix buffer handling of PS_MODE commands and responses
      libertas: don't clear priv->dnld_sent after sending sleep confirm
      libertas: handle HOST_AWAKE event by sending WAKEUP_CONFIRM comma=
nd
      libertas: allow for PS mode to be disabled when firmware doesn't =
support it
      libertas: Check for PS mode support on USB devices
      libertas: reduce explicit references to priv->cur_cmd->cmdbuf
      libertas: use priv->upld_buf for command responses
      libertas: discard DEFER responses to commands; let the timeout tr=
igger
      libertas: make lbs_submit_command always 'succeed' and set comman=
d timer
      libertas: submit RSSI command on tx timeout, to check whether mod=
ule is dead
      libertas: convert RADIO_CONTROL to a direct command
      libertas: convert INACTIVITY_TIMEOUT to a direct command
      libertas: convert SLEEP_PARAMS to a direct command
      libertas: convert SET_WEP to a direct command
      libertas: convert ENABLE_RSN to a direct command
      libertas: change inference about buffer size in lbs_cmd()
      libertas: convert SUBSCRIBE_EVENT to a direct command
      libertas: remove check for driver_lock in lbs_interrupt()

Divy Le Ray (11):
      cxgb3 - fix MSI-X failure path
      cxgb3 - Use wild card for PCI subdevice ID match
      cxgb3 - Fix resources release.
      cxgb3 - Add EEH support
      cxgb3 - FW upgrade
      cxgb3 - fix interaction with pktgen
      cxgb3 - sysfs methods clean up
      cxgb3 - HW set up updates
      cxgb3 - Fix I/O synchronization
      cxgb3 - parity initialization for T3C adapters.
      cxgb3 - Fix EEH, missing softirq blocking

Dmitry Torokhov (1):
      P54: use temporary variables to reduce size of generated code

Eliezer Tamir (1):
      add bnx2x driver for BCM57710

Emmanuel Grumbach (3):
      iwlwifi-ht: move 4965 SCD registers to iwl-prph.h
      iwlwifi: move 3945 SCD registers to iwl-prph.h
      iwlwifi: add 5965 SCD registers to iwl-prph.h

=46lorian Fainelli (1):
      Add me as maintainer of the RDC r6040 driver

=46rancois Romieu (9):
      sundance: SIOCDEVPRIVATE pollution
      r6040: compile error
      r6040: remove virt_to_bus
      r6040: erroneous dev->priv
      r6040: cleanups
      sis190: add cmos ram access code for the SiS19x/968 chipset pair
      sis190: remove duplicate INIT_WORK
      sis190: mdio operation failure is not correctly detected
      sis190: scheduling while atomic error

=46rank Lichtenheld (2):
      b43: silence a bogus gcc warning
      b43legacy: properly fix a bogus gcc warning

Grant Likely (1):
      gianfar driver: eliminate compiler warnings and unnecessary macro=
s

Holger Schurig (18):
      libertas: move wlan_*_association_work from header to c file
      libertas: move to uniform lbs_/LBS_ namespace
      libertas: clean up association debug messages
      libertas: remove arbitrary typedefs
      libertas: rework event subscription
      libertas: tweak association debug output
      libertas: tweak tx path debugging
      libertas: remove numprobes
      libertas: remove user-specified channel list
      libertas: less eventcause shifts
      libertas: remove cmd_ctrl_node->cmdflags
      libertas: remove cmd_ctrl_node->status
      libertas: make more functions static
      libertas: handy function to call firmware commands
      libertas: fix data packet size errors
      libertas: implement new scanning logic
      libertas: endianness fixes
      libertas: fix use-after-free error

Ian Schram (5):
      iwlwifi: fix various spelling and typos
      iwlwifi: rename iwl_eeprom_aqcuire_semaphore to _acquire_
      iwlwifi: Two comments in iwl-3945.c were longer than 80 columns
      iwlwifi: Beautify by removing superfluous newlines and code
      iwlwifi: remove late null-check and duplicate bug_on

Ivo van Doorn (25):
      rt2x00: Move quality statistics into seperate structure
      rt2x00: Use enum defines
      rt2x00: Correctly translate mac80211 antenna setup to rt2x00
      rt2x00: SW diversity should default to antenna B
      rt2x00: Remove rt2x00_clear_link
      rt2x00: Implement SW diversity
      rt2x00: Cleanup if-statements
      rt2x00: Release rt2x00 2.0.11
      rt2x00: Disable RX when switching antenna
      rt2x00: Split rt61/rt73 antenna selection into RX and TX antenna
      rt2x00: Input-polldev requires input device
      rt2x00: Detect initial rfkill state on register
      rt2x00: Remove unused variables
      rt2x00: Remove data_desc structure
      rt2x00: Release rt2x00 2.0.12
      rt2x00: Move duplicate code into rt2x00pci_txdone()
      rt2x00: Replace DRV_NAME with KBUILD_MODNAME
      rt2x00: Extend PLCP descriptor definition for rt2400pci
      rt2x00: Move register value/offset files into new folder
      rt2x00: Add chipset version to chipset debugfs entry
      rt2x00: Add skb descriptor
      rt2x00: Add TX/RX frame dumping facility
      rt2x00: Use IEEE80211_IF_TYPE_INVALID directly
      rt2x00: Cleanup rfkill
      rt2x00: Release rt2x00 2.0.13

Jay Vosburgh (1):
      [BONDING]: Documentation update

Jeff Garzik (10):
      hamradio/scc: kill unnecessary use of 'irq' function arg
      [netdrvr] irq handler minor cleanups in several drivers
      [netdrvr] ibmlana: modularization cleanup
      [netdrvr] ibmlana: move away from legacy MCA API
      [netdrvr] netxen: checkpatch fixes (98% trim trailing whitespace)
      drivers/net/r6040: fix obvious problems (but more remain)
      wireless: checkpatch cleanups
      [netdrvr] checkpatch cleanups
      drivers/net/cxgb3: trim trailing whitespace
      wireless/iwl: fix namespace breakage

Jes Sorensen (1):
      iwlwifi: disable interrupts before calling request_irq

Joe Perches (9):
      [E1000]: Convert regtest macro's to functions
      [E1000E]: convert register test macros to functions
      drivers/net/chelsio: Add missing "space"
      drivers/net/cxgb3: Add missing "space"
      drivers/net/ixgb: Add missing "space"
      drivers/net/netxen: Add missing "space"
      drivers/net/wan: Add missing "space"
      drivers/net/sk98lin: Add missing "space"
      drivers/net: Add missing "space"

Johannes Berg (3):
      b43: include full 64-bit timestamp in monitor mode
      b43: include FCS in frames handed to mac80211
      b43legacy: include full 64-bit timestamp in monitor mode

John W. Linville (3):
      iwlwifi: remove redundant initialization of final_mode
      rt2x00: correct "skb_buff" typo
      iwlwifi: fix-up merge fall-out after namespace separation

Komuro (1):
      axnet_cs: use spin_lock_irqsave instead of spin_lock + disable_ir=
q

Larry Finger (13):
      b43legacy: LED triggers support
      b43legacy: RF-kill support
      b43legacy: Use input-polldev for the rfkill switch
      b43legacy: Rewrite pwork locking
      ssb: Add new SPROM structure while keeping the old
      ssb: Convert to use of the new SPROM structure
      b44: Convert to use of the new SPROM structure
      b43: Convert to use of the new SPROM structure
      b43legacy: Convert to use of the new SPROM structure
      ssb: Remove the old, now unused, data structures
      b43: Changes to enable BCM4311 rev 02 with wireless core revision=
 13
      rt2x00: Remove redundant code in rfkill setup
      b43legacy: Fix rfkill radio LED

Lee Schermerhorn (1):
      bnx2x depends on ZLIB_INFLATE

Li Zefan (1):
      libertas: don't cast a pointer to pointer of

Matheos Worku (1):
      ixgb: enable sun hardware support for broadcom phy

Matthias Kaehlcke (2):
      Prism54: Convert mgmt_sem to the mutex API
      PLIP driver: convert the semaphore killed_timer_sem to completion

Mattias Nissler (6):
      rt2x00: Fix antenna selection.
      rt2x00: Rework rt61 antenna selection.
      rt2x00: Rework rt73 antenna selection
      rt2x00: Correctly set ACK bit in tx descriptors
      rt2x00: Allow rt61 to catch up after a missing tx report
      rt2x00: Only update rssi average approximation on receiving beaco=
n frames.

Michael Buesch (6):
      b43legacy: Remove set_key callback
      b43: Dereference of wl->current_dev must be protected by wl->mute=
x
      b43: Use the retry limit parameters from mac80211
      b43: consistent naming for ieee80211_ops
      b43: Fix ofdmtab write regression
      b43: Fix for broken transmission

Miguel Bot=F3n (1):
      iwlwifi: remove redundant declaration of 'iwl3945_priv' and 'iwl4=
965_priv' structs

Mohamed Abbas (4):
      iwl4965: fix cannot find a suitable rate issue
      iwlwifi: enhance WPA authenication stability
      iwlwifi: fix ucode assertion for RX queue overrun
      iwlwifi: avoid firmware command sending if rfkill is enabled

Olof Johansson (13):
      pasemi_mac: RX/TX ring management cleanup
      pasemi_mac: Move register definitions to include/asm-powerpc
      pasemi: DMA engine management library
      pasemi_mac: Convert to new dma library
      pasemi_mac: performance tweaks
      pasemi_mac: Fix TX cleaning
      pasemi_mac: Improve RX interrupt mitigation
      pasemi_mac: Software-based LRO support
      pasemi_mac: SKB unmap optimization
      pasemi_mac: Remove SKB copy/recycle logic
      pasemi_mac: Print warning when not attaching to a PHY
      pasemi_mac: Don't enable RX/TX without a link (if possible)
      pasemi: export pasemi_dma_init()

Patrick McHardy (1):
      [E1000]: Secondary unicast address support

Pekka Enberg (8):
      ipg: remove old contact information
      ipg: remove boolean macros
      ipg: remove IPG_DEV_KFREE_SKB macro
      ipg: remove driver version
      ipg: remove commented out code
      ipg: remove some internal comments
      ipg: naming convention fixes
      ipg: fix checkpatch reported errors

Peter Korsgaard (1):
      dm9601: Consolidate common parts of dm_write_*_async

Ramkrishna Vepa (2):
      S2io: Fixes to enable multiple transmit fifo support
      S2io: Fixes to enable multiple transmit fifos

Reinette Chatre (3):
      MAINTAINERS: Add Reinette Chatre to iwlwifi & ipw2100/ipw2200
      iwlwifi: continue namespace changes - fix CONFIG variables
      iwlwifi: remove HT code from iwl-3945.h

Robert P. J. Day (1):
      pcmcia net: use roundup_pow_of_two() macro instead of grotesque l=
oop

Roel Kluin (1):
      wireless: fix '!x & y' typo's

Ron Rindjunsky (8):
      iwlwifi: 802.11n remove unnecessary config dependency
      iwlwifi: 802.11n new framework structures preperation
      iwlwifi: 802.11n configuring hw_mode parameters to support HT in =
A/G
      iwlwifi: 802.11n handling probe request HT IE
      iwlwifi: 802.11n comply HT self configuration flow with mac80211 =
framework
      iwlwifi: 802.11n comply HT add station flow with mac80211 framewo=
rk
      iwlwifi: 802.11n comply HT rate scaling flows with mac80211 frame=
work
      iwlwifi: 802.11n add support to 8K A-MSDU Rx frames

Sreenivasa Honnur (1):
      [S2IO]: Support for add/delete/store/restore ethernet addresses

Stefan Roese (1):
      net: NEWEMAC: Fix problem with mtu > 4080 on non TAH equipped 4xx=
 PPC's

Stefano Brivio (8):
      b43legacy: use the retry limits provided by mac80211
      b43legacy: use a consistent naming scheme for the ops
      b43legacy: rewrite and fix rfkill initialization
      b43: rewrite A PHY initialization
      b43/b43legacy: fix my copyright notices
      b43legacy: fix kconfig dependecies for rfkill and leds
      b43: reinit on too many PHY TX errors
      b43legacy: reinit on too many PHY TX errors

Sten Wang (1):
      [NET]: Add support for the RDC R6040 Fast Ethernet controller

Stephen Hemminger (4):
      sky2: align IP header on Rx if possible
      sky2: rx allocation threshold change
      sky2: support for Yukon Supreme
      sky2: version 1.21

Thomas Bogendoerfer (3):
      SGISEEQ: use cached memory access to make driver work on IP28
      SGISEEQ: use cached memory access to make driver work on IP28
      SGISEEQ: fix oops when doing ifconfig down; ifconfig up

Tomas Winkler (14):
      iwlwifi: Add erp_ie_changed hanlder
      iwlwifi: renaming last_used and first_empty
      iwlwifi: rs-4965 fix return values
      iwlwifi: add TGN flag to qos parameters
      iwlwifi: remove cck_flag from iwl_driver_hw_info
      iwlwifi: remove cck_power_index_compensation
      iwlwifi: using PCI_DEVICE macro
      iwlwifi: replace restricted_reg with prph
      iwlwifi: rename restricted_mem to targ_mem
      iwlwifi: replacing wording restricted to nic access in iwl-io
      iwlwifi: Renames struct fw_image_desc to struct fw_desc
      iwlwifi: Support for uCode without init and bsm section
      iwlwifi: fix compliation warnings
      iwlwifi: add missing comments

Zhu Yi (9):
      iwlwifi: Update iwlwifi version stamp to 1.1.18
      iwlwifi: Update iwlwifi version stamp to 1.1.19
      iwlwifi: replace 0x8086 with PCI_VENDOR_ID_INTEL
      remove unused iwl4965_init_hw_rates function
      iwl4965: fix rxon flags set to wrong value for A mode in .erp_ie_=
changed
      iwlwifi: update version number to 1.2.22
      iwlwifi: cache mac80211 conf setting during a hardware scan
      iwlwifi: proper monitor support
      iwlwifi: skip mac80211 conf during a hardware scan and replay it =
afterwards

mabbas (2):
      iwlwifi: accept up to 4K frame size on Rx side to fit A-MSDU fram=
e
      iwl4965: exclude 60M rate from probe request

 Documentation/networking/bonding.txt             |  204=20
 MAINTAINERS                                      |   16=20
 arch/ia64/hp/sim/simeth.c                        |    5=20
 arch/powerpc/platforms/pasemi/Makefile           |    2=20
 arch/powerpc/platforms/pasemi/dma_lib.c          |  488 +
 arch/powerpc/platforms/pasemi/pasemi.h           |    1=20
 arch/ppc/8260_io/enet.c                          |    4=20
 arch/ppc/8260_io/fcc_enet.c                      |    4=20
 drivers/net/3c501.c                              |  232=20
 drivers/net/3c507.c                              |   15=20
 drivers/net/3c515.c                              |    2=20
 drivers/net/7990.c                               |    8=20
 drivers/net/Kconfig                              |   43=20
 drivers/net/Makefile                             |    3=20
 drivers/net/a2065.c                              |   10=20
 drivers/net/amd8111e.c                           |    4=20
 drivers/net/at1700.c                             |    5=20
 drivers/net/b44.c                                |    8=20
 drivers/net/bnx2.c                               |    4=20
 drivers/net/bnx2x.c                              | 9064 ++++++++++++++=
+++++++++
 drivers/net/bnx2x.h                              | 1071 ++
 drivers/net/bnx2x_fw_defs.h                      |  198=20
 drivers/net/bnx2x_hsi.h                          | 2176 +++++
 drivers/net/bnx2x_init.h                         |  564 +
 drivers/net/bnx2x_init_values.h                  | 6368 ++++++++++++++=
++
 drivers/net/bnx2x_reg.h                          | 4394 +++++++++++
 drivers/net/cassini.c                            |    4=20
 drivers/net/chelsio/cxgb2.c                      |    2=20
 drivers/net/chelsio/espi.c                       |    2=20
 drivers/net/chelsio/espi.h                       |    1=20
 drivers/net/chelsio/sge.c                        |    4=20
 drivers/net/chelsio/sge.h                        |    2=20
 drivers/net/cpmac.c                              |    3=20
 drivers/net/cxgb3/adapter.h                      |    1=20
 drivers/net/cxgb3/cxgb3_main.c                   |  253=20
 drivers/net/cxgb3/cxgb3_offload.c                |   19=20
 drivers/net/cxgb3/firmware_exports.h             |   20=20
 drivers/net/cxgb3/regs.h                         |  270=20
 drivers/net/cxgb3/sge.c                          |  120=20
 drivers/net/cxgb3/t3_hw.c                        |  167=20
 drivers/net/cxgb3/version.h                      |    4=20
 drivers/net/cxgb3/xgmac.c                        |   10=20
 drivers/net/declance.c                           |    6=20
 drivers/net/e100.c                               |  204=20
 drivers/net/e1000/e1000_ethtool.c                |   86=20
 drivers/net/e1000/e1000_hw.h                     |   88=20
 drivers/net/e1000/e1000_main.c                   |  195=20
 drivers/net/e1000e/82571.c                       |   11=20
 drivers/net/e1000e/defines.h                     |    1=20
 drivers/net/e1000e/e1000.h                       |    1=20
 drivers/net/e1000e/ethtool.c                     |   89=20
 drivers/net/e1000e/hw.h                          |   86=20
 drivers/net/e1000e/lib.c                         |   39=20
 drivers/net/e1000e/netdev.c                      |   61=20
 drivers/net/e1000e/param.c                       |    7=20
 drivers/net/e1000e/phy.c                         |    3=20
 drivers/net/eepro100.c                           |   92=20
 drivers/net/eexpress.c                           |   12=20
 drivers/net/enc28j60.c                           | 1600 ++++
 drivers/net/enc28j60_hw.h                        |  309=20
 drivers/net/forcedeth.c                          |   46=20
 drivers/net/gianfar_sysfs.c                      |   50=20
 drivers/net/hamradio/6pack.c                     |    2=20
 drivers/net/hamradio/mkiss.c                     |    2=20
 drivers/net/hamradio/scc.c                       |    8=20
 drivers/net/hp100.c                              |    2=20
 drivers/net/ibm_newemac/core.c                   |   14=20
 drivers/net/ibmlana.c                            |  192=20
 drivers/net/ipg.c                                |  286=20
 drivers/net/ipg.h                                |   99=20
 drivers/net/irda/irport.h                        |    2=20
 drivers/net/irda/smsc-ircc2.c                    |   17=20
 drivers/net/irda/via-ircc.c                      |   12=20
 drivers/net/ixgb/ixgb_hw.c                       |   82=20
 drivers/net/ixgb/ixgb_hw.h                       |   25=20
 drivers/net/ixgb/ixgb_ids.h                      |    4=20
 drivers/net/ixgb/ixgb_main.c                     |   10=20
 drivers/net/ixgbe/ixgbe.h                        |    8=20
 drivers/net/ixgbe/ixgbe_82598.c                  |  156=20
 drivers/net/ixgbe/ixgbe_common.c                 |   12=20
 drivers/net/ixgbe/ixgbe_ethtool.c                |    3=20
 drivers/net/ixgbe/ixgbe_main.c                   |   29=20
 drivers/net/ixgbe/ixgbe_phy.h                    |    1=20
 drivers/net/ixgbe/ixgbe_type.h                   |   65=20
 drivers/net/lp486e.c                             |    9=20
 drivers/net/mac89x0.c                            |    2=20
 drivers/net/mace.c                               |   10=20
 drivers/net/myri10ge/myri10ge.c                  |    2=20
 drivers/net/netxen/netxen_nic.h                  |   30=20
 drivers/net/netxen/netxen_nic_ethtool.c          |   28=20
 drivers/net/netxen/netxen_nic_hw.c               |   31=20
 drivers/net/netxen/netxen_nic_hw.h               |   18=20
 drivers/net/netxen/netxen_nic_init.c             |   98=20
 drivers/net/netxen/netxen_nic_isr.c              |   15=20
 drivers/net/netxen/netxen_nic_main.c             |   41=20
 drivers/net/netxen/netxen_nic_niu.c              |   64=20
 drivers/net/netxen/netxen_nic_phan_reg.h         |   15=20
 drivers/net/ns83820.c                            |    9=20
 drivers/net/pasemi_mac.c                         |  934 +-
 drivers/net/pasemi_mac.h                         |  365=20
 drivers/net/pcmcia/axnet_cs.c                    |   16=20
 drivers/net/pcmcia/fmvj18x_cs.c                  |    7=20
 drivers/net/pcmcia/pcnet_cs.c                    |    4=20
 drivers/net/pcnet32.c                            |    2=20
 drivers/net/plip.c                               |   10=20
 drivers/net/pppol2tp.c                           |    2=20
 drivers/net/qla3xxx.c                            |   46=20
 drivers/net/qla3xxx.h                            |   55=20
 drivers/net/r6040.c                              | 1096 ++
 drivers/net/rrunner.c                            |    2=20
 drivers/net/s2io-regs.h                          |   16=20
 drivers/net/s2io.c                               |  536 -
 drivers/net/s2io.h                               |   26=20
 drivers/net/sgiseeq.c                            |  245=20
 drivers/net/sis190.c                             |   21=20
 drivers/net/sis900.c                             |    6=20
 drivers/net/sk98lin/skgemib.c                    |    2=20
 drivers/net/sk98lin/skgepnmi.c                   |   14=20
 drivers/net/sk98lin/skgesirq.c                   |    2=20
 drivers/net/skfp/hwmtm.c                         |    4=20
 drivers/net/skfp/smt.c                           |    2=20
 drivers/net/sky2.c                               |  117=20
 drivers/net/sky2.h                               |   13=20
 drivers/net/slhc.c                               |   12=20
 drivers/net/slip.c                               |  367=20
 drivers/net/smc9194.c                            |    2=20
 drivers/net/sundance.c                           |   26=20
 drivers/net/sungem.c                             |   10=20
 drivers/net/sungem.h                             |    8=20
 drivers/net/sunhme.c                             |   51=20
 drivers/net/sunhme.h                             |   12=20
 drivers/net/tehuti.c                             |   10=20
 drivers/net/tg3.c                                |    2=20
 drivers/net/tokenring/olympic.c                  |   10=20
 drivers/net/tokenring/olympic.h                  |   18=20
 drivers/net/tokenring/smctr.c                    |    4=20
 drivers/net/tulip/de4x5.c                        |    4=20
 drivers/net/tun.c                                |    2=20
 drivers/net/ucc_geth.c                           |    3=20
 drivers/net/usb/dm9601.c                         |   53=20
 drivers/net/via-rhine.c                          |    2=20
 drivers/net/wan/farsync.c                        |   11=20
 drivers/net/wan/hdlc_ppp.c                       |    2=20
 drivers/net/wan/hdlc_raw_eth.c                   |    2=20
 drivers/net/wan/lmc/lmc_main.c                   |    6=20
 drivers/net/wan/lmc/lmc_media.c                  |    8=20
 drivers/net/wan/lmc/lmc_proto.c                  |    2=20
 drivers/net/wan/lmc/lmc_proto.h                  |    2=20
 drivers/net/wan/pc300_drv.c                      |    8=20
 drivers/net/wan/pc300_tty.c                      |   12=20
 drivers/net/wan/sbni.c                           |    4=20
 drivers/net/wan/sdla.c                           |    5=20
 drivers/net/wan/wanxl.c                          |    4=20
 drivers/net/wireless/Makefile                    |    3=20
 drivers/net/wireless/airo.c                      |   10=20
 drivers/net/wireless/atmel.c                     |    3=20
 drivers/net/wireless/b43/Makefile                |    1=20
 drivers/net/wireless/b43/b43.h                   |   17=20
 drivers/net/wireless/b43/debugfs.c               |    2=20
 drivers/net/wireless/b43/dma.c                   |   32=20
 drivers/net/wireless/b43/leds.c                  |   10=20
 drivers/net/wireless/b43/lo.c                    |    8=20
 drivers/net/wireless/b43/main.c                  |  219=20
 drivers/net/wireless/b43/main.h                  |    2=20
 drivers/net/wireless/b43/phy.c                   |  672 -
 drivers/net/wireless/b43/phy.h                   |   24=20
 drivers/net/wireless/b43/tables.c                |  112=20
 drivers/net/wireless/b43/tables.h                |   12=20
 drivers/net/wireless/b43/wa.c                    |  674 +
 drivers/net/wireless/b43/wa.h                    |    7=20
 drivers/net/wireless/b43/xmit.c                  |    8=20
 drivers/net/wireless/b43legacy/Kconfig           |   16=20
 drivers/net/wireless/b43legacy/Makefile          |   29=20
 drivers/net/wireless/b43legacy/b43legacy.h       |   18=20
 drivers/net/wireless/b43legacy/debugfs.c         |    2=20
 drivers/net/wireless/b43legacy/ilt.c             |    2=20
 drivers/net/wireless/b43legacy/leds.c            |  417 -
 drivers/net/wireless/b43legacy/leds.h            |   61=20
 drivers/net/wireless/b43legacy/main.c            |  380=20
 drivers/net/wireless/b43legacy/main.h            |    2=20
 drivers/net/wireless/b43legacy/phy.c             |   40=20
 drivers/net/wireless/b43legacy/phy.h             |    2=20
 drivers/net/wireless/b43legacy/radio.c           |   29=20
 drivers/net/wireless/b43legacy/radio.h           |    4=20
 drivers/net/wireless/b43legacy/rfkill.c          |  204=20
 drivers/net/wireless/b43legacy/rfkill.h          |   59=20
 drivers/net/wireless/b43legacy/xmit.c            |    7=20
 drivers/net/wireless/hostap/hostap_hw.c          |    2=20
 drivers/net/wireless/ipw2100.c                   |    3=20
 drivers/net/wireless/iwlwifi/Kconfig             |  164=20
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h | 1639 ++++
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h    |  152=20
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |  616 +
 drivers/net/wireless/iwlwifi/iwl-3945-io.h       |  431 +
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |  146=20
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h       |   41=20
 drivers/net/wireless/iwlwifi/iwl-3945.c          |  715 +
 drivers/net/wireless/iwlwifi/iwl-3945.h          |  950 ++
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h | 2562 ++++++
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h    |  152=20
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       | 2062 ++++-
 drivers/net/wireless/iwlwifi/iwl-4965-io.h       |  431 +
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |  984 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |   91=20
 drivers/net/wireless/iwlwifi/iwl-4965.c          | 1387 ++-
 drivers/net/wireless/iwlwifi/iwl-4965.h          | 1192 ++-
 drivers/net/wireless/iwlwifi/iwl-channel.h       |  161=20
 drivers/net/wireless/iwlwifi/iwl-commands.h      | 1734 ----
 drivers/net/wireless/iwlwifi/iwl-debug.h         |  152=20
 drivers/net/wireless/iwlwifi/iwl-eeprom.h        |  336=20
 drivers/net/wireless/iwlwifi/iwl-hw.h            |  537 -
 drivers/net/wireless/iwlwifi/iwl-io.h            |  470 -
 drivers/net/wireless/iwlwifi/iwl-priv.h          |  308=20
 drivers/net/wireless/iwlwifi/iwl-prph.h          |   61=20
 drivers/net/wireless/iwlwifi/iwl3945-base.c      | 3016 +++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c      | 3566 ++++-----
 drivers/net/wireless/iwlwifi/iwlwifi.h           |  708 -
 drivers/net/wireless/libertas/11d.c              |  154=20
 drivers/net/wireless/libertas/11d.h              |   26=20
 drivers/net/wireless/libertas/README             |   40=20
 drivers/net/wireless/libertas/assoc.c            |  458 -
 drivers/net/wireless/libertas/assoc.h            |   32=20
 drivers/net/wireless/libertas/cmd.c              | 1396 ++-
 drivers/net/wireless/libertas/cmd.h              |   61=20
 drivers/net/wireless/libertas/cmdresp.c          |  662 -
 drivers/net/wireless/libertas/debugfs.c          | 1492 ---
 drivers/net/wireless/libertas/debugfs.h          |   12=20
 drivers/net/wireless/libertas/decl.h             |  102=20
 drivers/net/wireless/libertas/defs.h             |   67=20
 drivers/net/wireless/libertas/dev.h              |  176=20
 drivers/net/wireless/libertas/ethtool.c          |  114=20
 drivers/net/wireless/libertas/host.h             |  392=20
 drivers/net/wireless/libertas/hostcmd.h          |  143=20
 drivers/net/wireless/libertas/if_cs.c            |   88=20
 drivers/net/wireless/libertas/if_sdio.c          |   88=20
 drivers/net/wireless/libertas/if_sdio.h          |    4=20
 drivers/net/wireless/libertas/if_usb.c           |  726 -
 drivers/net/wireless/libertas/if_usb.h           |  108=20
 drivers/net/wireless/libertas/join.c             |  313=20
 drivers/net/wireless/libertas/join.h             |   38=20
 drivers/net/wireless/libertas/main.c             | 1330 +--
 drivers/net/wireless/libertas/rx.c               |  223=20
 drivers/net/wireless/libertas/scan.c             | 1192 +--
 drivers/net/wireless/libertas/scan.h             |   94=20
 drivers/net/wireless/libertas/tx.c               |  253=20
 drivers/net/wireless/libertas/types.h            |   25=20
 drivers/net/wireless/libertas/wext.c             |  867 +-
 drivers/net/wireless/libertas/wext.h             |   14=20
 drivers/net/wireless/orinoco.c                   |  544 -
 drivers/net/wireless/orinoco.h                   |   12=20
 drivers/net/wireless/p54common.c                 |    2=20
 drivers/net/wireless/p54pci.c                    |   77=20
 drivers/net/wireless/prism54/isl_ioctl.c         |    4=20
 drivers/net/wireless/prism54/islpci_dev.c        |    2=20
 drivers/net/wireless/prism54/islpci_dev.h        |    3=20
 drivers/net/wireless/prism54/islpci_mgt.c        |    4=20
 drivers/net/wireless/rt2x00/rt2400pci.c          |  173=20
 drivers/net/wireless/rt2x00/rt2400pci.h          |   24=20
 drivers/net/wireless/rt2x00/rt2500pci.c          |  141=20
 drivers/net/wireless/rt2x00/rt2500pci.h          |    4=20
 drivers/net/wireless/rt2x00/rt2500usb.c          |  206=20
 drivers/net/wireless/rt2x00/rt2500usb.h          |   17=20
 drivers/net/wireless/rt2x00/rt2x00.h             |  214=20
 drivers/net/wireless/rt2x00/rt2x00config.c       |  100=20
 drivers/net/wireless/rt2x00/rt2x00debug.c        |  240=20
 drivers/net/wireless/rt2x00/rt2x00debug.h        |    4=20
 drivers/net/wireless/rt2x00/rt2x00dev.c          |  301=20
 drivers/net/wireless/rt2x00/rt2x00dump.h         |  121=20
 drivers/net/wireless/rt2x00/rt2x00firmware.c     |    5=20
 drivers/net/wireless/rt2x00/rt2x00lib.h          |    8=20
 drivers/net/wireless/rt2x00/rt2x00mac.c          |    7=20
 drivers/net/wireless/rt2x00/rt2x00pci.c          |   96=20
 drivers/net/wireless/rt2x00/rt2x00pci.h          |   12=20
 drivers/net/wireless/rt2x00/rt2x00rfkill.c       |   39=20
 drivers/net/wireless/rt2x00/rt2x00ring.h         |   37=20
 drivers/net/wireless/rt2x00/rt2x00usb.c          |   77=20
 drivers/net/wireless/rt2x00/rt2x00usb.h          |   19=20
 drivers/net/wireless/rt2x00/rt61pci.c            |  398 -
 drivers/net/wireless/rt2x00/rt61pci.h            |   14=20
 drivers/net/wireless/rt2x00/rt73usb.c            |  232=20
 drivers/net/wireless/rt2x00/rt73usb.h            |   14=20
 drivers/net/wireless/rtl8187_rtl8225.c           |    8=20
 drivers/net/wireless/wavelan.c                   |    2=20
 drivers/net/wireless/wavelan_cs.c                |   10=20
 drivers/net/wireless/zd1211rw/Kconfig            |    7=20
 drivers/net/wireless/zd1211rw/Makefile           |    3=20
 drivers/net/wireless/zd1211rw/zd_chip.c          |  126=20
 drivers/net/wireless/zd1211rw/zd_chip.h          |   60=20
 drivers/net/wireless/zd1211rw/zd_def.h           |    5=20
 drivers/net/wireless/zd1211rw/zd_ieee80211.c     |  196=20
 drivers/net/wireless/zd1211rw/zd_ieee80211.h     |   49=20
 drivers/net/wireless/zd1211rw/zd_mac.c           | 1541 +--
 drivers/net/wireless/zd1211rw/zd_mac.h           |  117=20
 drivers/net/wireless/zd1211rw/zd_netdev.c        |  264=20
 drivers/net/wireless/zd1211rw/zd_netdev.h        |   45=20
 drivers/net/wireless/zd1211rw/zd_rf.c            |    5=20
 drivers/net/wireless/zd1211rw/zd_rf.h            |    5=20
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c     |    5=20
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c    |    5=20
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c     |    5=20
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c     |    7=20
 drivers/net/wireless/zd1211rw/zd_usb.c           |  289=20
 drivers/net/wireless/zd1211rw/zd_usb.h           |   36=20
 drivers/net/xen-netfront.c                       |    2=20
 drivers/ssb/b43_pci_bridge.c                     |    1=20
 drivers/ssb/main.c                               |   10=20
 drivers/ssb/pci.c                                |  221=20
 include/asm-powerpc/pasemi_dma.h                 |  467 +
 include/linux/if_frad.h                          |    2=20
 include/linux/if_tun.h                           |    4=20
 include/linux/pci_ids.h                          |    3=20
 include/linux/ssb/ssb.h                          |   71=20
 include/linux/ssb/ssb_regs.h                     |   59=20
 net/ieee80211/ieee80211_wx.c                     |    2=20
 314 files changed, 57148 insertions(+), 22551 deletions(-)
