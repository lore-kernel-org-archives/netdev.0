From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [mini-RFT] r8169 and amd64
Date: Wed, 20 Oct 2004 23:03:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020210350.GA12577@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Could someone with an amd64 system test the r8169 driver in Jeff's -netdev
with PCI DAC enabled and send me the values of the command and status
registers which are displayed when the PCI error happen ?

One just need to give an "use_dac=1" option to the r8169 module.

Apparently the 8169 does not hesitate to issue harmless PCI error. They could
be identified and thus ignored.


Alternate location for the relevant patch against 2.6.9:
http://www.fr.zoreil.com/people/francois/misc/20041020-2.6.9-r8169.c-test.patch 

Thank you for your attention.

--
Ueimor
