From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 83/84]
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1551:19: sparse: incorrect
 type in return expression (different base types)
Date: Sun, 18 Nov 2012 16:43:11 +0800
Message-ID: <50a89f9f.oTR4cFYr2+4dX7g+%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45872 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab2KRInb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2012 03:43:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   75fe83c32248d99e6d5fe64155e519b78bb90481
commit: 6d973cb163aede0b4a414abfda42d1bc35bfd7f9 [83/84] qlcnic: fix sparse warnings


sparse warnings:

drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1366:27: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1366:27:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1366:27:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1369:19: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1383:14: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1383:14:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1383:14:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1384:16: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1384:16:    expected unsigned char [unsigned] [usertype] no_ops
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1384:16:    got restricted __le32 [usertype] no_ops
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1394:70: sparse: incorrect type in argument 3 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1394:70:    expected unsigned int [unsigned] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1394:70:    got restricted __le32 [usertype] val1
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1403:65: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1408:65: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1411:54: sparse: restricted __le16 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1413:56: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1413:70: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1418:50: sparse: restricted __le16 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1426:46: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1426:46:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1426:46:    got restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1428:66: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1428:66:    expected restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1428:66:    got unsigned int [unsigned] [addressable] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1432:46: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1432:46:    expected unsigned int [unsigned] [addressable] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1432:46:    got restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1434:46: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1434:46:    expected unsigned int [unsigned] [addressable] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1434:46:    got restricted __le32 [usertype] val1
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1436:46: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1436:46:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1436:46:    got restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1440:38: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1440:38:    expected unsigned int [unsigned] [addressable] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1440:38:    got restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1444:46: sparse: invalid assignment: &=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1444:46:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1444:46:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1445:38: sparse: invalid assignment: |=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1445:38:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1445:38:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1446:38: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1446:38:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1446:38:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1447:66: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1447:66:    expected restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1447:66:    got unsigned int [unsigned] [addressable] [assigned] [usertype] data
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1469:13: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1469:13:    expected unsigned int [unsigned] [usertype] val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1469:13:    got restricted __le32 [usertype] val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1470:34: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1471:42: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1471:42:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1471:42:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1472:41: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1472:41:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1472:41:    got restricted __le32 [usertype] read_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1473:27: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1473:27:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1473:27:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1474:27: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1474:27:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1474:27:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1475:21: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1475:21:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1475:21:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1477:23: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1489:14: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1489:14:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1489:14:    got restricted __le32 [usertype] read_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1492:34: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1493:42: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1493:42:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1493:42:    got restricted __le32 [usertype] sel_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1494:22: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1494:22:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1494:22:    got restricted __le32 [usertype] read_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1497:35: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1497:35:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1497:35:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1500:24: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1500:24:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1500:24:    right side has type restricted __le16
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1502:19: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1514:45: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1515:28: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1517:27: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1517:27:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1517:27:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1518:28: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1520:19: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1532:17: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1532:17:    expected unsigned int [unsigned] [usertype] fl_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1532:17:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1533:19: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1548:27: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1548:27:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1548:27:    got restricted __le32 [usertype] <noident>
+ drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1551:19: sparse: incorrect type in return expression (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1551:19:    expected unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1551:19:    got restricted __le32 [usertype] size
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1563:13: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1563:13:    expected unsigned int [unsigned] [usertype] val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1563:13:    got restricted __le16 [usertype] init_tag_val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1565:27: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1566:41: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1566:41:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1566:41:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1567:41: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1567:41:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1567:41:    got restricted __le32 [usertype] ctrl_addr
+ drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1567:60: sparse: cast from restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1568:22: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1568:22:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1568:22:    got restricted __le32 [usertype] read_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1572:35: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1572:35:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1572:35:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1576:21: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1576:21:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1576:21:    right side has type restricted __le16
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1578:18: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1591:13: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1591:13:    expected unsigned int [unsigned] [usertype] val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1591:13:    got restricted __le16 [usertype] init_tag_val
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1592:21: sparse: cast from restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1593:19: sparse: cast from restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1595:27: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1596:41: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1596:41:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1596:41:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1597:21: sparse: cast from restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1598:49: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1598:49:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1598:49:    got restricted __le32 [usertype] ctrl_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1599:47: sparse: cast from restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1603:48: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1603:48:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1603:48:    got restricted __le32 [usertype] ctrl_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1617:22: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1617:22:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1617:22:    got restricted __le32 [usertype] read_addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1621:35: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1621:35:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1621:35:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1625:21: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1625:21:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1625:21:    right side has type restricted __le16
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1627:18: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1639:18: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1639:18:    expected int [signed] reg_read
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1639:18:    got restricted __le32 [usertype] size
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1640:14: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1640:14:    expected unsigned int [unsigned] [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1640:14:    got restricted __le32 [usertype] addr
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1673:35: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1673:35:    expected unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1673:35:    got restricted __le32 [usertype] <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1681:19: sparse: incorrect type in return expression (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1681:19:    expected unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1681:19:    got restricted __le32 [usertype] size
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1721:31: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1749:33: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1750:35: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1750:35:    left side has type int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1750:35:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1763:20: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1763:20:    expected unsigned int [unsigned] [usertype] no_entries
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1763:20:    got restricted __le32 [usertype] num_entries
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1765:22: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1765:22:    expected unsigned int [unsigned] [usertype] entry_offset
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1765:22:    got restricted __le32 [usertype] offset
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1766:31: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1766:31:    expected restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1766:31:    got int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1767:31: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1767:31:    expected restricted __le32 <noident>
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1767:31:    got unsigned int [unsigned] [usertype] fw_version
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1771:49: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1773:38: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1773:38:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1773:38:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1779:39: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1794:28: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1794:28:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1794:28:    right side has type restricted __le32
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1795:30: sparse: invalid assignment: +=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1795:30:    left side has type unsigned int
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:1795:30:    right side has type restricted __le32

vim +1551 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c

18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1542  	for (i = 0; i < size; i++) {
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1543  		addr = fl_addr & 0xFFFF0000;
6d973cb1 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c Sony Chacko         2012-11-17  1544  		qlcnic_write_dump_reg(FLASH_ROM_WINDOW, base, addr);
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1545  		addr = LSW(fl_addr) + FLASH_ROM_DATA;
6d973cb1 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c Sony Chacko         2012-11-17  1546  		qlcnic_read_dump_reg(addr, base, &val);
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1547  		fl_addr += 4;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12 @1548  		*buffer++ = cpu_to_le32(val);
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1549  	}
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1550  	readl(base + QLCNIC_FLASH_SEM2_ULK);
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12 @1551  	return rom->size;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1552  }
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1553  
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1554  static u32
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1555  qlcnic_dump_l1_cache(struct qlcnic_adapter *adapter,
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1556  	struct qlcnic_dump_entry *entry, u32 *buffer)
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1557  {
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1558  	int i;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1559  	u32 cnt, val, data, addr;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1560  	void __iomem *base = adapter->ahw->pci_base0;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1561  	struct __cache *l1 = &entry->region.cache;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1562  
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1563  	val = l1->init_tag_val;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1564  
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1565  	for (i = 0; i < l1->no_ops; i++) {
6d973cb1 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c Sony Chacko         2012-11-17  1566  		qlcnic_write_dump_reg(l1->addr, base, val);
6d973cb1 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c Sony Chacko         2012-11-17 @1567  		qlcnic_write_dump_reg(l1->ctrl_addr, base, LSW(l1->ctrl_val));
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1568  		addr = l1->read_addr;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1569  		cnt = l1->read_addr_num;
18f2f616 drivers/net/qlcnic/qlcnic_hw.c                 Anirban Chakraborty 2011-05-12  1570  		while (cnt) {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
