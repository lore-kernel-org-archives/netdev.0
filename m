From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 16 Jan 2007 16:55:24 -0200
Message-ID: <20070116185524.GA5681@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:50848 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbXAPS7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 13:59:34 -0500
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Announcing an updated patch of the Marvell Libertas 8388 802.11 USB
driver.

Diff can be found at 
http://dev.laptop.org/~marcelo/libertas-8388-16012007.patch

_Please_ review, this driver is targeted for mainline inclusion.

There have been almost no comments resulting from the first submission.

Changes since v1:

- reset usb device if boot2 init command fails
- resend initial boot command in case of non-response
- inform which command is being resent due to timeout
- do not evaluate boot command response if boot2 < v3106
- allocate bulk_out_buffer with GFP_KERNEL instead of GFP_DMA
- add event capability reporting
- remove "@file" and "@brief" headers from beginning of files
- remove now obsolete comments about driver building from README
- remove unused Makefile.old
- remove -DUPDATE_BOOT2_BY_MFG from Makefile
- fix typo and add "8388" to Kconfig entry
- remove unecessary commentary from if_bootcmd.c
- remove unecessary static attr of "struct HostCmd_DS_MESH_ACCESS" instances
- remove SLEEP_PERIOD command support code (not implemented in fw)
- hexdump should use KERN_DEBUG
- disable debugging output by default
- add might_sleep() to wait command response path
- Don't sleep inside get_wireless_stats
- version bump correction (320p0 instead of 321p0)
- destroy association worker in wlan_add_card EH path
- proper pending command accounting
- move radiotap definitions to include/net/ieee80211_radiotap.h
- added support for MPP activation/deactivation through sysfs
- remove pointer to dev structure on libertas_devs in card removal



