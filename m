From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169 tx_timeout recovery and automatic DAC step-down
Date: Thu, 30 Sep 2004 23:36:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930213637.GA12646@electric-eye.fr.zoreil.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com> <200409231558.29821.jdmason@us.ltcfwd.linux.ibm.com> <20040923220519.GD8018@electric-eye.fr.zoreil.com> <200409231840.12539.jdmason@us.ltcfwd.linux.ibm.com> <20040926230928.GA28817@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040926230928.GA28817@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]

Errr... Oops. :o*

Ok, try #2. Now I can recover from the infamous PCI DAC error on my 32
bit box. Any taker on amd64 ?

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-bk15/r8169-200.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-bk15/r8169-210.patch

These patches apply against 2.6.9-rc2-mm2 or -netdev. If people want to use
a vanilla post 2.6.9-rc2-bk15, the patches below must be applied first:

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-bk15/r8169-2.6.9-rc2-bk15-dac-revert.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc2-bk15/r8169-rc2-mm2.patch

--
Ueimor
