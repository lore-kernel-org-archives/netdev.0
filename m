From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 0/7] 2.6.6-rc3-mm1 - description of the r8169 queue
Date: Sat, 1 May 2004 02:23:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022308.A32762@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With some delay, the following patches include Jon D Mason's NAPI changes
(+ fixes) and code from Andy Lutomirski with minor changes.
I have not moved the initialization of the phy timer in the pci probe
routine as:
- I believe it belongs to the netdevice;
- it should work as is without significant change for the user.

If someone sees a good reason to move it, just complain (with an axe).

The patches apply to 2.6.6-rc3 as well as to 2.6.6-rc3-mm1.

All the patches are merged in a single patch against 2.6.6-rc3 available at:
http://www.fr.zoreil.com/people/francois/misc/20040501-2.6.6-rc3-r8169.c-test.patch

The patches are archived below as well:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.6-rc3

If the patches prove to behave decently on 2.6, a backport for 2.4.x will be
generated.

--
Ueimor
