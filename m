From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169 tx_timeout recovery and automatic DAC step-down
Date: Mon, 27 Sep 2004 01:09:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926230928.GA28817@electric-eye.fr.zoreil.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com> <200409231558.29821.jdmason@us.ltcfwd.linux.ibm.com> <20040923220519.GD8018@electric-eye.fr.zoreil.com> <200409231840.12539.jdmason@us.ltcfwd.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <200409231840.12539.jdmason@us.ltcfwd.linux.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Untested patches of the day (it's late and I need to sleep):

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-mm2/r8169-200.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-mm2/r8169-210.patch

The first one should perform a clean reset of the device under TX_TIMEOUT.
The second one should be able to detect a broken setup wrt pci dac
transaction and downgrade the advertised features of the driver accordingly.

The quality of my untested patches past 00 AM is not guaranteed.

--
Ueimor
