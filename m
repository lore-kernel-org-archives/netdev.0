From: Arun Murthy <arun.murthy@stericsson.com>
Subject: [PATCHv3 0/4] modem_shm: U8500 SHaRed Memory driver(SHRM)
Date: Mon, 27 Aug 2012 11:19:25 +0530
Message-ID: <1346046569-8050-1-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arun.murthy@stericsson.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <gregkh@linuxfoundation.org>,
	<alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In u8500 platform the communication between the APE(Application Processor) and
the modem subsystem(CMT) is by means of a shared DDR. The series of patches
include a protocol called ShaRed Memory(SHRM) protocol for communicating
between the APE and the CMT.
Interrupt generation registers in CMT and PRCMU on APE side are used to support
the shrm protocol.

v2 - Included netdev mailing list
v3 - Implemented comments from Alan Cox and Greg KH

Arun Murthy (4):
  modem_shm: Add Modem Access Framework
  modem_shm: Register u8500 client for MAF
  modem_shm: u8500-shm: U8500 Shared Memory Driver
  Doc: Add u8500_shrm document

 Documentation/DocBook/Makefile              |    2 +-
 Documentation/DocBook/shrm.tmpl             |  125 +++
 Documentation/modem_shm/u8500_shrm.txt      |  254 +++++
 drivers/Kconfig                             |    2 +
 drivers/Makefile                            |    1 +
 drivers/modem_shm/Kconfig                   |   22 +
 drivers/modem_shm/Makefile                  |    3 +
 drivers/modem_shm/modem_access.c            |  413 +++++++
 drivers/modem_shm/modem_u8500.c             |   96 ++
 drivers/modem_shm/u8500_shm/Kconfig         |   43 +
 drivers/modem_shm/u8500_shm/Makefile        |    7 +
 drivers/modem_shm/u8500_shm/shrm.h          |   23 +
 drivers/modem_shm/u8500_shm/shrm_char.c     |  816 ++++++++++++++
 drivers/modem_shm/u8500_shm/shrm_config.h   |  114 ++
 drivers/modem_shm/u8500_shm/shrm_driver.c   |  733 ++++++++++++
 drivers/modem_shm/u8500_shm/shrm_driver.h   |  226 ++++
 drivers/modem_shm/u8500_shm/shrm_fifo.c     |  838 ++++++++++++++
 drivers/modem_shm/u8500_shm/shrm_ioctl.h    |   43 +
 drivers/modem_shm/u8500_shm/shrm_net.c      |  313 ++++++
 drivers/modem_shm/u8500_shm/shrm_net.h      |   46 +
 drivers/modem_shm/u8500_shm/shrm_private.h  |  184 +++
 drivers/modem_shm/u8500_shm/shrm_protocol.c | 1591 +++++++++++++++++++++++++++
 include/linux/modem_shm/modem.h             |   64 ++
 include/linux/modem_shm/modem_client.h      |   55 +
 24 files changed, 6013 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/DocBook/shrm.tmpl
 create mode 100644 Documentation/modem_shm/u8500_shrm.txt
 create mode 100644 drivers/modem_shm/Kconfig
 create mode 100644 drivers/modem_shm/Makefile
 create mode 100644 drivers/modem_shm/modem_access.c
 create mode 100644 drivers/modem_shm/modem_u8500.c
 create mode 100644 drivers/modem_shm/u8500_shm/Kconfig
 create mode 100644 drivers/modem_shm/u8500_shm/Makefile
 create mode 100644 drivers/modem_shm/u8500_shm/shrm.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_char.c
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_config.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_driver.c
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_driver.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_fifo.c
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_ioctl.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_net.c
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_net.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_private.h
 create mode 100644 drivers/modem_shm/u8500_shm/shrm_protocol.c
 create mode 100644 include/linux/modem_shm/modem.h
 create mode 100644 include/linux/modem_shm/modem_client.h

-- 
1.7.4.3
