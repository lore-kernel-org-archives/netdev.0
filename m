From: Hans Schwimmbeck <hans@schwimmbeck.de>
Subject: forcedeth 0.18 on nForce
Date: Thu, 20 Nov 2003 09:50:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311200950.58211.hans@schwimmbeck.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

System:
Mainboard MSI nForce K7N415 Pro
OS SUSE 8.2
updated kernel k_athlon-2.4.20-100 and kernel-source-2.4.20.SuSE-100

I compiled forcedeth 0.18 as external module by "make" using the makefile
---------
KERNELDIR = /usr/src/linux
CFLAGS = -D__KERNEL__ -DMODULE -I$(KERNELDIR)/include -O

all: forcedeth.o
---------

forcedeth.o is replacing nvnet.o and working so far without any problem. The 
only output I get in my /var/log/messages is:
---------
Nov 20 08:22:52 linux kernel: forcedeth.c: Reverse Engineered nForce ethernet 
driver. Version 0.18.
Nov 20 08:22:52 linux kernel: PCI: Setting latency timer of device 00:04.0 to 
64
Nov 20 08:22:52 linux kernel: eth0: forcedeth.c: subsystem: 01462:373c
---------

Is it possible to publish forcedeth.c in future releases as I prefer compiling 
as an external module to patching the sources?
Anyway - thank's a lot for the great driver, hopefully Nvidia will think about 
their non-disclosure policy now.

Hans
