From: Guenter Roeck <linux@roeck-us.net>
Subject: Adding support for ARINC429 into the Linux kernel
Date: Wed, 19 Jun 2013 13:29:55 -0700
Message-ID: <20130619202954.GA5594@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I have been asked to explore options for adding ARINC 429 support [1]
into the Linux kernel, primarily to support devices from Holt Integrated
Circuits [2] (the request is unrelated to the chip manufacturer).

ARINC429 is a protocol which is widely used in commercial airplanes. 

There are various chips supporting this protocol available, as well as
out-of-tree Linux support. The drivers I have looked at implement it
either as character device or misc device and typically pass raw receive
data to userspace.

I can see a number of options for going forward:
1) Implement as character device (or possibly misc device) and pass
   raw data to/from user space
   1a) Just implement a driver for the specific chips
   2b) Implement some kind of generic infrastructure
2) Implement as network driver with a new address family, similar to,
   say, AF_CAN.

Any thoughts / suggestions which approach would be better and, most of all,
which approach might have a better chance of being accepted upstream ?

Thanks,
Guenter

--
[1] http://en.wikipedia.org/wiki/ARINC_429
[2] http://www.holtic.com/category/352-arinc-429.aspx
