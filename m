From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Mon, 17 Dec 2007 18:24:04 -0500
Message-ID: <47670514.4030204@garzik.org>
References: <20071216043419.GF3096@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45836 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbXLQXYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:24:07 -0500
In-Reply-To: <20071216043419.GF3096@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John W. Linville wrote:
> Jeff,
> 
> Some more patches intended for 2.6.25...  There are a bunch of libertas
> patches in there, as well as some iwlwifi cleanups from the last merge
> and a couple of b43 fixes resulting from a regression in an earlier
> patch already queued in netdev-2.6#upstream.
> 
> Let me know if there are any problems!
> 
> Thanks,
> 
> John
> 
> ---
> 
> Individual patches available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik
> 
> ---
> 
> The following changes since commit 9c8e86195d75a1f4875e9ced083a015a99cec94e:
>   John W. Linville (1):
>         rt2x00: correct "skb_buff" typo
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik ..BRANCH.NOT.VERIFIED..
> 
> Dan Williams (11):
>       orinoco: always use latest BSS info when caching scan results
>       libertas: make lbs_cmd() usage nicer
>       libertas: clean up is_command_allowed_in_ps()
>       libertas: clean up direct command handling
>       libertas: add simple copyback command callback
>       libertas: convert GET_HW_SPEC to a direct command
>       libertas: rename and re-type bufvirtualaddr to cmdbuf
>       libertas: fix case of FWT_ACCESS_LIST_ROUTE and FWT_ACCESS_LIST_NEIGHBOR commands
>       libertas: convert DATA_RATE to a direct command
>       libertas: convert RF_CHANNEL to a direct command
>       libertas: endianness fixes for get_channel/set_channel
> 
> David Woodhouse (76):
>       libertas: Fix memory leak of RX skbs
>       libertas: Remove cmd_oid from struct cmd_ctrl_node
>       libertas: Consolidate lbs_host_to_card_done() function.
>       libertas: Don't claim to have checksummed incoming packets.
>       libertas: Move SET_BOOT2_VER command to if_usb where it belongs
>       libertas: Zero 'pdata_size' field in cmd_ctrl_node reliably.
>       libertas: Byteswap cmdptr->size in lbs_cmd()
>       libertas: Use lbs_cmd() for setting Boot2 version
>       libertas: Remove SET_BOOT2_VER support from the Big Switch Statement.
>       libertas: Fix endianness in boot2_version handling.
>       libertas: when usb_submit_usb fails, include the error code in the printk
>       libertas: Switch to using a callback function pointer for commands
>       libertas: Don't set IW_ENCODE_NOKEY when returning WEP keys.
>       libertas: Fix up error handling in lbs_setuserscan()
>       libertas: kill adapter->nr_cmd_pending
>       libertas: switch lbs_cmd() to take a callback function pointer
>       libertas: clean up lbs_thread() to make it slightly more readable
>       libertas: fix lbs_rtap attribute in sysfs
>       libertas: kill TxLockFlag
>       libertas: kill struct lbs_adapter
>       libertas: use lbs_host_to_card_done() in lbs_tx_timeout()
>       libertas: cope with device which already has firmware loaded
>       libertas: stop debugfs code looking at cmdpendingq
>       libertas: kill internal tx queue for PS mode
>       libertas: kill SendSinglePacket() function.
>       libertas: move lbs_hard_start_xmit() into tx.c
>       libertas: kill lbs_process_tx() by merging it into lbs_hard_start_xmit()
>       libertas: clean up lbs_hard_start_xmit()
>       libertas: kill lbs_pre_start_xmit(), lib_mesh_pre_start_xmit()
>       libertas: stop using ieee80211 for radiotap device
>       libertas: set dev_addr on rtap device
>       libertas: TX packet is radiotap iff it comes from rtap_dev
>       libertas: free successfully transmitted skbs again
>       libertas: refactor the 'should I sleep?' decision in lbs_thread()
>       libertas: Move actual transmission to main thread
>       libertas: remove unreachable code from process_rxed_802_11_packet()
>       libertas: fix error cases in lbs_process_rxed_802_11_packet()
>       libertas: kill lbs_upload_tx_packet()
>       libertas: kill (IS,SET,UNSET)_MESH_FRAME.
>       libertas: add opaque extra argument to cmd callback function
>       libertas: clean up lbs_interrupt()
>       libertas: remove pre_open_check()
>       libertas: make rtap and normal modes mutually exclusive, clean up open/stop
>       libertas: improve reliability of firmware reloading on USB
>       libertas: switch to a waitqueue and timer for handling USB firmware load
>       libertas: don't run thread while firmware not yet ready
>       libertas: switch USB cardp->priv to 'struct lbs_private *' and resulting fix
>       libertas: move removal of lbs_rtap file to lbs_stop_card()
>       libertas: wait for 'firmware ready' event from firmware after loading
>       libertas: fix debug output in lbs_cmd_copyback() function.
>       libertas: convert CMD_MESH_ACCESS to a direct command
>       libertas: remove casts from lbs_cmd() and lbs_cmd_with_response() macros
>       libertas: make some more functions static
>       libertas: fix sparse endianness warnings in scan.c
>       libertas: add lbs_mesh sysfs attribute for enabling mesh
>       libertas: kill references to mesh autostart
>       libertas: kill rx_urb_recall and eth_dev members of struct usb_card_rec
>       libertas: whitespace cleanup in host.h
>       libertas: allow get/set SSID on mshX device
>       libertas: allow setting channel on mshX device
>       libertas: add missing newline on debug message
>       libertas: disable mesh temporarily while setting eth channel/assoc
>       libertas: add debugging output to lbs_mesh_config()
>       libertas: be more careful about command responses matching cur_cmd
>       libertas: add missing newlines in debugging statements
>       libertas: slight cleanup of netif queue stop/wake
>       libertas: add lbs_host_sleep_cfg() command function
>       libertas: switch lbs_cmd() to take a _pointer_ to the command structure
>       libertas: make worker thread not freezable
>       libertas: implement suspend and resume core methods
>       libertas: implement suspend/resume for USB devices
>       libertas: add ethtool support for wake-on-lan configuration
>       libertas: make lbs_update_channel() function non-static
>       libertas: cope with both old and new mesh TLV values
>       libertas: pass channel argument directly to lbs_mesh_config()
>       libertas: use spin_is_locked() instead of spin_trylock() in lbs_interrupt()
> 
> Holger Schurig (8):
>       libertas: remove cmd_ctrl_node->cmdflags
>       libertas: remove cmd_ctrl_node->status
>       libertas: make more functions static
>       libertas: handy function to call firmware commands
>       libertas: fix data packet size errors
>       libertas: implement new scanning logic
>       libertas: endianness fixes
>       libertas: fix use-after-free error
> 
> Li Zefan (1):
>       libertas: don't cast a pointer to pointer of
> 
> Michael Buesch (2):
>       b43: Fix ofdmtab write regression
>       b43: Fix for broken transmission
> 
> Reinette Chatre (1):
>       iwlwifi: remove HT code from iwl-3945.h
> 
> Tomas Winkler (2):
>       iwlwifi: fix compliation warnings
>       iwlwifi: add missing comments

Pulled.

PLEASE verify iwlwifi and zd1121rw drivers, as soon as netdev-2.6.git 
mirrors out, because I had to do some hand-merging when bringing the .24 
fixes into #upstream.

	Jeff




