From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] [RFT] 2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:08:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327030853.A30849@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The recent changes to the r8169 driver turned it into something quite
different from the sis190 driver whence it (apparently) originated.

The following serie of patches resyncs the sis190 driver with the r8169
one while making it compliant (?) wrt the DMA API.

I'll review it more closely once I have got some sleep but if some happy
tester wants to contribute, he will be welcome.

The patches compile, they are untested and should apply to nearly anything
2.6.x as -mm does not include patches to the sis190.c.

--
Ueimor
