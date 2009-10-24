From: Frederik Nosi <fredin77@yahoo.com>
Subject: iwl3945, after a while stops working with "No space for Tx"
Date: Sat, 24 Oct 2009 06:44:31 -0700 (PDT)
Message-ID: <177253.23325.qm@web53903.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomas.
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753713AbZJXNvZ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
first sorry if somebody is not the right contact, got the adressess from ./scripts/get_maintainer.pl -f drivers/net/wireless/iwlwifi.
>From some kernel versions now, after some time that im using this card it stops working and on messages i get this errors:

Oct 24 14:38:24 kotys NetworkManager: <info>  Activation (wlan0) Stage 5 of 5 (IP Configure Commit) complete.
[snip pulseaudio's stuppid log spam warning]
Oct 24 14:40:07 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
Oct 24 14:40:09 kotys pulseaudio[16469]: sap.c: sendmsg() failed: Invalid argument
Oct 24 14:40:10 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_SCAN_CMD: time out after 500ms.
Oct 24 14:40:11 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
Oct 24 14:40:11 kotys kernel: iwl3945 0000:04:00.0: Error sending POWER_TABLE_CMD: time out after 500ms.
Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0: set power fail, ret = -110
Oct 24 14:40:14 kotys kernel: No probe response from AP 00:1c:df:82:63:c9 after 500ms, disconnecting.
Oct 24 14:40:14 kotys NetworkManager: <info>  (wlan0): supplicant connection state:  completed -> disconnected
Oct 24 14:40:14 kotys NetworkManager: <info>  (wlan0): supplicant connection state:  disconnected -> scanning
Oct 24 14:40:14 kotys pulseaudio[16469]: sap.c: sendmsg() failed: Invalid argument
Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_RXON: time out after 500ms.
Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0: Error setting new configuration (-110).
Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_SCAN_CMD: time out after 500ms.
Oct 24 14:40:15 kotys kernel: wlan0: direct probe to AP 00:1c:df:82:63:c9 (try 1)
Oct 24 14:40:15 kotys NetworkManager: <info>  (wlan0): supplicant connection state:  scanning -> associating
Oct 24 14:40:15 kotys kernel: wlan0: direct probe to AP 00:1c:df:82:63:c9 (try 2)
Oct 24 14:40:15 kotys kernel: wlan0: direct probe to AP 00:1c:df:82:63:c9 (try 3)
Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_RXON: time out after 500ms.
Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0: Error setting new configuration (-110).
Oct 24 14:40:15 kotys kernel: wlan0: direct probe to AP 00:1c:df:82:63:c9 timed out
Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0: Error sending REPLY_RXON: time out after 500ms.
Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0: Error setting new configuration (-110).


When this happens i am able to use the card only after reloading the related modules, iwl3945 ecc. But the problem happens again after some minutes that im connected.

Kernel is 2.6.32-rc5 but his started happening around 2.6.31, not sure exactly what version as i update kernel often. Firmware is iwl3945-ucode-15.32.2.9.

Every other info that you need just ask. I hope i dont have to bisect as this is the laptop i use for work too, but if it's needed i'll do.

I'm not subscribed on any ML, so in case please cc me.

Thanks for all the work!

F.



      
