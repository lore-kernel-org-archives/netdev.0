From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: eepro100 broken on ARM by 2.6.11-rc1 changes
Date: Tue, 15 Feb 2005 22:10:20 +0100
Message-ID: <20050215211020.GB566@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

eepro100 seems to have stopped working between 2.6.10 and 2.6.11-rc2
on an embedded ARM platform.  In 2.6.10 I would see this:

eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
eth0: 0000:01:00.0, 00:00:50:14:56:11, IRQ 40.
  Receiver lock-up bug exists -- enabling work-around.
  Board assembly 698247-003, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x8b51f404).
  Receiver lock-up workaround activated.
DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[...]

But now I just see this:

eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[...]

Copying the eepro100 driver from 2.6.10 into 2.6.11-rc4 makes things
work again on 2.6.11-rc4.

Anyone else seeing this?


cheers,
Lennert
