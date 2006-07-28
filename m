From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 28 Jul 2006 13:52:37 +0200
Message-ID: <20060728115237.GF21733@deprecation.cyrius.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:45324 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S1161128AbWG1Lwi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 07:52:38 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060728111534.GD25854@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Lennert Buytenhek <buytenh@wantstofly.org> [2006-07-28 13:15]:
> > - an ethtool dump of the registers. I don't know if Realtek's
> > driver support but it can help even the in-kernel driver
> 
> I'll ask someone else with the same board to do the test and will
> post the results.

Here's the output using the r8169 driver:

RealTek RTL-8110 registers:
------------------------------
0x00: MAC Address                      00:14:fd:10:27:74
0x08: Multicast Address Filter     0x00000000 0x00000000
0x10: Dump Tally Counter Command   0xd7bbfec0 0xfb74b6fb
0x20: Tx Normal Priority Ring Addr 0x00000000 0x00000000
0x28: Tx High Priority Ring Addr   0xfffc3f00 0xfef7f6ad
0x30: Flash memory read/write                 0x00000000
0x34: Early Rx Byte Count                              0
0x36: Early Rx Status                               0x00
0x37: Command                                       0x00
      Rx off, Tx off
0x3C: Interrupt Mask                              0x0000

0x3E: Interrupt Status                            0x0000

0x40: Tx Configuration                        0x10000000
0x44: Rx Configuration                        0x00000002
0x48: Timer count                             0x95887845
0x4C: Missed packet counter                     0x000000
0x50: EEPROM Command                                0x00
0x51: Config 0                                      0x04
0x52: Config 1                                      0x1f
0x53: Config 2                                      0x10
0x54: Config 3                                      0x20
0x55: Config 4                                      0x80
0x56: Config 5                                      0x01
0x58: Timer interrupt                         0x00000000
0x5C: Multiple Interrupt Select                   0x0000
0x60: PHY access                              0x80001000
0x64: TBI control and status                  0x00000000
0x68: TBI Autonegotiation advertisement (ANAR)    0x0000
0x6A: TBI Link partner ability (LPAR)             0x0000
0x6C: PHY status                                    0x6b
0x84: PM wakeup frame 0            0xbcfeef7f 0xdffffe9f
0x8C: PM wakeup frame 1            0xabf7cf3f 0xfffbdbbf
0x94: PM wakeup frame 2 (low)      0xdfbbfedf 0xbfbffffd
0x9C: PM wakeup frame 2 (high)     0xaa75befc 0xcb5feaf9
0xA4: PM wakeup frame 3 (low)      0xbbdf6fdf 0xff7e75b7
0xAC: PM wakeup frame 3 (high)     0xbbdffbf9 0xfbfcffff
0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbffa7f
0xBC: PM wakeup frame 4 (high)     0xae9fbdcd 0x32c8bbff
0xC4: Wakeup frame 0 CRC                          0x9aff
0xC6: Wakeup frame 1 CRC                          0xfdbf
0xC8: Wakeup frame 2 CRC                          0xaeff
0xCA: Wakeup frame 3 CRC                          0x6bfe
0xCC: Wakeup frame 4 CRC                          0xdc2f
0xDA: RX packet maximum size                      0x3fff
0xE0: C+ Command                                  0x2028
      RX checksumming
      PCI Multiple RW
0xE2: Interrupt Mitigation                        0x0000
      TxTimer:       0
      TxPackets:     0
      RxTimer:       0
      RxPackets:     0
0xE4: Rx Ring Addr                 0x07bd4000 0x00000000
0xEC: Early Tx threshold                            0x3f

-- 
Martin Michlmayr
http://www.cyrius.com/
