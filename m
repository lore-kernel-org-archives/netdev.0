From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [rft/update] r8169 changes in 2.6.x
Date: Wed, 23 Feb 2005 00:48:10 +0100
Message-ID: <20050222234810.GA17303@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Jon Mason <jdmason@us.ibm.com>,
        Richard Dawe <rich@phekda.gotadsl.co.uk>,
        Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

An update of the r8169 driver is available for the 2.6.11-rc4 kernel.

Noticable changes:
- better handling of PHY as found on Acer Aspire 1524WLMi (Richard Dawe);
- fix a bug triggered when the device is brought down then up again;
- avoid a few lost/screaming interrupts;
- closed a race when a change of mtu is issued during network activity;
- fix VLAN on big-endian hosts (is someone using it apart from me ?);
- merge relevant changes from Realtek's 2.2 driver.

If it worked for you before, you should not notice anything.

Patch against 2.6.10-rc4:
- http://www.fr.zoreil.com/~romieu/misc/20050222-2.6.11-rc4-r8169.c-test.patch

Patch-script directory:
- http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc4/r8169/

Patch-script tarball:
- http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc4/r8169-blob.tar.bz2

The 2.4.x backport will be updated later this week.

As usual, success/regression reports will be welcome.

Thank you for your attention.

--
Ueimor
