From: remy.gauguey@mindspeed.com
Subject: Linux 2.6 crypto API and HW accelerators
Date: Tue, 4 May 2004 15:39:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4ED7CD00.900586C8-ONC1256E8A.00491716-C1256E8A.004B08FD__26628.9532105022$1083678681@nice.mindspeed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <20040504.224906.123086020.yoshfuji@linux-ipv6.org>
To: linux-crypto@nl.linux.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm currently working on a ARM920T based network processor with arm-linux
kernel 2.6.5.
This device has a crypto hardware accelerator dedicated to IPsec.
In ESP mode the device can do authentication (SHA-1, MD5) as well as
encryption (AES, TDES in CBC or ECB mode) in one pass.
Unfortunately current Linux 2.6 crypto API doesn't support this kind of
hardware accelerator. Current crypto module relies on crypto algorithms
which are called for a single operation and for each block.

Then, I would like to know if other people are working on the hardware
crypto support in kernel 2.6.x.
If so, what would be the plan ? crypto api improvement or new IPsec
specific hardware support ?

Thanks for any feedback or info.

Remy Gauguey




