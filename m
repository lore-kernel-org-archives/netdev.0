From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH iproute2 0/3] CAN Filter/Classifier
Date: Fri, 25 May 2012 11:11:43 +0200
Message-ID: <1337937106-7640-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, pisa@cmp.felk.cvut.cz,
	sojkam1@fel.cvut.cz, oliver@hartkopp.net,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAN classifier may be used with any available qdisc on Controller
Area Network (CAN) frames passed through AF_CAN networking subsystem.
The classifier classifies CAN frames according to their identifiers.
It can be used on CAN frames with both SFF or EFF identifiers.

The filtering rules for EFF frames are stored in an array, which
is traversed during classification. A bitmap is used to store SFF
rules -- one bit for each ID.

More info about the project:
http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf


Rostislav Lisovy (3):
  Added missing can.h
  CAN Filter/Classifier -- Source code
  CAN Filter/Classifier -- Documentation

 include/linux/can.h     |  112 ++++++++++++++++++++++
 include/linux/pkt_cls.h |   10 ++
 man/man8/tc-can.8       |   97 +++++++++++++++++++
 tc/Makefile             |    1 +
 tc/f_can.c              |  238 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 458 insertions(+)
 create mode 100644 include/linux/can.h
 create mode 100644 man/man8/tc-can.8
 create mode 100644 tc/f_can.c

-- 
1.7.9.5

