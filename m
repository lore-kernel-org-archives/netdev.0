From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk patches] 2.6 net driver updates
Date: Tue, 19 Aug 2003 00:27:29 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030819042729.GA1360@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: torvalds@osdl.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.6

Patch is also available from

ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-test3-bk6-netdrvr1.patch.bz2

This will update the following files:

 Documentation/networking/8139too.txt |    1 
 drivers/net/8139cp.c                 |    4 
 drivers/net/8139too.c                |   10 
 drivers/net/Kconfig                  |    2 
 drivers/net/eexpress.c               |    2 
 drivers/net/tulip/Kconfig            |    8 
 drivers/net/wireless/Kconfig         |    2 
 drivers/net/wireless/airo.c          |  522 +++++++++++++++++++----------------
 drivers/net/wireless/atmel.c         |   21 -
 drivers/net/wireless/atmel_cs.c      |    1 
 10 files changed, 313 insertions(+), 260 deletions(-)

through these ChangeSets:

<alan@lxorguk.ukuu.org.uk> (03/08/19 1.1240)
   [netdrvr eexpress] fix buglet in skb_padto conversion

<jgarzik@redhat.com> (03/08/19 1.1239)
   [netdrvr de2104x] fix Kconfig help text to reflect reality

<srk@thekelleys.org.uk> (03/08/19 1.1238)
   [wireless atmel] minor updates
   
   1) Add another card to the PCMCIA card database.
   2) Fix a bug in wireless extensions.
   3) Remove extra code for compilation without the firmware loader
   4) force-enable CRC32 and FW_LOADER in Kconfig.
   

<jgarzik@redhat.com> (03/08/19 1.1237)
   [netdrvr 8139too] add adapter to supported list, in docs

<akropel1@rochester.rr.com> (03/08/19 1.1236)
   [netdrvr] fix seeq8005 entry help text in Kconfig

<sziwan@hell.org.pl> (03/08/18 1.1235)
   [netdrvr 8139too] fix resume behavior

<matthewn@snapgear.com> (03/08/18 1.1234)
   [netdrvr 8139cp] fix h/w vlan offload
   
   It wants big endian vlan tags.  IEEE, or just weird?

<javier@tudela.mad.ttd.net> (03/08/18 1.1233)
   [wireless airo] Replaces task queues by simpler kernel_thread
