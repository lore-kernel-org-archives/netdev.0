From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH iproute2 0/3] CAN Filter/Classifier
Date: Mon,  4 Jun 2012 18:09:06 +0200
Message-ID: <1338826149-11604-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This classifier classifies CAN frames (AF_CAN) according to their
identifiers. This functionality can not be easily achieved with
existing classifiers, such as u32. This classifier can be used
with any available qdisc and it is able to classify both SFF
or EFF frames.

The filtering rules for EFF frames are stored in an array, which
is traversed during classification. A bitmap is used to store SFF
rules -- one bit for each ID.

More info about the project:
http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf


Rostislav Lisovy (3):
  Add missing can.h
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

