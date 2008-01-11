From: Andrei Popa <andrei.popa@i-neo.ro>
Subject: [oops] 2.6.23.9
Date: Sat, 12 Jan 2008 00:47:57 +0200
Message-ID: <1200091677.12201.5.camel@ierdnac>
Reply-To: andrei.popa@i-neo.ro
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.204.20.254] ([85.204.20.254]:53050 "EHLO megainternet.ro"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761472AbYAKWy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 17:54:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux version 2.6.23.9 vanilla

Jan  7 02:24:11 eunite BUG: scheduling while atomic:
mii-tool/0x00000002/31658
Jan  7 02:24:11 eunite [<c02fd920>] schedule+0x27a/0x35e
Jan  7 02:24:11 eunite [<c011dbd7>] __mod_timer+0xac/0xbc
Jan  7 02:24:11 eunite [<c02fe2bb>] schedule_timeout+0x43/0x9f
Jan  7 02:24:11 eunite [<c011dd92>] process_timeout+0x0/0x5
Jan  7 02:24:11 eunite [<c011dd5e>] msleep+0xf/0x14
Jan  7 02:24:11 eunite [<c02242a9>] e1000_reset_hw+0x57/0x353
Jan  7 02:24:11 eunite [<c0219cca>] e1000_reset+0xa6/0x2ed
Jan  7 02:24:11 eunite [<c0219f8d>] e1000_down+0x7c/0xb1
Jan  7 02:24:11 eunite [<c021a253>] e1000_reinit_locked+0x37/0x76
Jan  7 02:24:11 eunite [<c021a3be>] e1000_ioctl+0x12c/0x280
Jan  7 02:24:11 eunite [<c021a292>] e1000_ioctl+0x0/0x280
Jan  7 02:24:11 eunite [<c029e861>] dev_ifsioc+0x2dc/0x30d
Jan  7 02:24:11 eunite [<c029f408>] dev_ioctl+0x1f8/0x32f
Jan  7 02:24:11 eunite [<c02948a5>] sock_ioctl+0x41/0x15f
Jan  7 02:24:11 eunite [<c0294864>] sock_ioctl+0x0/0x15f
Jan  7 02:24:11 eunite [<c015d6cf>] do_ioctl+0x1f/0x6d
Jan  7 02:24:11 eunite [<c015d76d>] vfs_ioctl+0x50/0x26e
Jan  7 02:24:11 eunite [<c01f3e9a>] tty_write+0x0/0x1b2
Jan  7 02:24:11 eunite [<c015d9bf>] sys_ioctl+0x34/0x51
Jan  7 02:24:11 eunite [<c010268e>] sysenter_past_esp+0x5f/0x85
Jan  7 02:24:11 eunite [<c02f0000>] fn_trie_insert+0x525/0x7f6
Jan  7 02:24:11 eunite =======================

Jan  7 02:24:55 eunite BUG: scheduling while atomic:
mii-tool/0x00000002/31668
Jan  7 02:24:55 eunite [<c02fd920>] schedule+0x27a/0x35e
Jan  7 02:24:55 eunite [<c02fe2bb>] schedule_timeout+0x43/0x9f
Jan  7 02:24:55 eunite [<c01bc290>] __delay+0x6/0x7
Jan  7 02:24:55 eunite [<c021fa67>] e1000_write_phy_reg_ex+0x45/0x8f
Jan  7 02:24:55 eunite [<c011dd92>] process_timeout+0x0/0x5
Jan  7 02:24:55 eunite [<c011dd5e>] msleep+0xf/0x14
Jan  7 02:24:55 eunite [<c0220ade>] e1000_phy_init_script+0x96/0x206
Jan  7 02:24:55 eunite [<c0222097>] e1000_phy_reset+0x57/0xa2
Jan  7 02:24:55 eunite [<c0222348>] e1000_setup_copper_link+0x266/0x12bc
Jan  7 02:24:55 eunite [<c0220f89>] e1000_read_eeprom+0x8c/0x2f2
Jan  7 02:24:55 eunite [<c0223f97>] e1000_setup_link+0x37c/0x4e5
Jan  7 02:24:55 eunite [<c022489f>] e1000_init_hw+0x2fa/0xb68
Jan  7 02:24:55 eunite [<c0118911>] do_wait+0x7d4/0xc46
Jan  7 02:24:55 eunite [<c022452a>] e1000_reset_hw+0x2d8/0x353
Jan  7 02:24:55 eunite [<c0219cea>] e1000_reset+0xc6/0x2ed
Jan  7 02:24:55 eunite [<c0219f8d>] e1000_down+0x7c/0xb1
Jan  7 02:24:55 eunite [<c021a253>] e1000_reinit_locked+0x37/0x76
Jan  7 02:24:55 eunite [<c021a3be>] e1000_ioctl+0x12c/0x280
Jan  7 02:24:55 eunite [<c021a292>] e1000_ioctl+0x0/0x280
Jan  7 02:24:55 eunite [<c029e861>] dev_ifsioc+0x2dc/0x30d
Jan  7 02:24:55 eunite [<c029f408>] dev_ioctl+0x1f8/0x32f
Jan  7 02:24:55 eunite [<c02948a5>] sock_ioctl+0x41/0x15f
Jan  7 02:24:55 eunite [<c0294864>] sock_ioctl+0x0/0x15f
Jan  7 02:24:55 eunite [<c015d6cf>] do_ioctl+0x1f/0x6d
Jan  7 02:24:55 eunite [<c015d76d>] vfs_ioctl+0x50/0x26e
Jan  7 02:24:55 eunite [<c01f3e9a>] tty_write+0x0/0x1b2
Jan  7 02:24:55 eunite [<c015d9bf>] sys_ioctl+0x34/0x51
Jan  7 02:24:55 eunite [<c010268e>] sysenter_past_esp+0x5f/0x85

an  7 02:24:55 eunite BUG: scheduling while atomic:
mii-tool/0x00000002/31668
Jan  7 02:24:55 eunite [<c02fd920>] schedule+0x27a/0x35e
Jan  7 02:24:55 eunite [<c02fe2bb>] schedule_timeout+0x43/0x9f
Jan  7 02:24:55 eunite [<c011dd92>] process_timeout+0x0/0x5
Jan  7 02:24:55 eunite [<c011dd5e>] msleep+0xf/0x14
Jan  7 02:24:55 eunite [<c022235c>] e1000_setup_copper_link+0x27a/0x12bc
Jan  7 02:24:55 eunite [<c0220f89>] e1000_read_eeprom+0x8c/0x2f2
Jan  7 02:24:55 eunite [<c0223f97>] e1000_setup_link+0x37c/0x4e5
Jan  7 02:24:55 eunite [<c022489f>] e1000_init_hw+0x2fa/0xb68
Jan  7 02:24:55 eunite [<c0118911>] do_wait+0x7d4/0xc46
Jan  7 02:24:55 eunite [<c022452a>] e1000_reset_hw+0x2d8/0x353
Jan  7 02:24:55 eunite [<c0219cea>] e1000_reset+0xc6/0x2ed
Jan  7 02:24:55 eunite [<c0219f8d>] e1000_down+0x7c/0xb1
Jan  7 02:24:55 eunite [<c021a253>] e1000_reinit_locked+0x37/0x76
Jan  7 02:24:55 eunite [<c021a3be>] e1000_ioctl+0x12c/0x280
Jan  7 02:24:55 eunite [<c021a292>] e1000_ioctl+0x0/0x280
Jan  7 02:24:55 eunite [<c029e861>] dev_ifsioc+0x2dc/0x30d
Jan  7 02:24:55 eunite [<c029f408>] dev_ioctl+0x1f8/0x32f
Jan  7 02:24:55 eunite [<c02948a5>] sock_ioctl+0x41/0x15f
Jan  7 02:24:55 eunite [<c0294864>] sock_ioctl+0x0/0x15f
Jan  7 02:24:55 eunite [<c015d6cf>] do_ioctl+0x1f/0x6d
Jan  7 02:24:55 eunite [<c015d76d>] vfs_ioctl+0x50/0x26e
Jan  7 02:24:55 eunite [<c01f3e9a>] tty_write+0x0/0x1b2
Jan  7 02:24:55 eunite [<c015d9bf>] sys_ioctl+0x34/0x51
Jan  7 02:24:55 eunite [<c010268e>] sysenter_past_esp+0x5f/0x85
Jan  7 02:24:55 eunite =======================


