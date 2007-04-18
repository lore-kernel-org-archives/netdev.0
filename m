From: Borislav Petkov <bbpetkov@yahoo.de>
Subject: [KJ] [PATCH] fix comments for register_netdev()
Date: Wed, 18 Apr 2007 14:49:52 +0200
Message-ID: <20070418124952.GA5948@zmei.tnic>
Reply-To: bbpetkov@yahoo.de
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.linux-foundation.org>
List-Help: <mailto:kernel-janitors-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.linux-foundation.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.linux-foundation.org
Errors-To: kernel-janitors-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Correct the function name in the comments supplied with register_netdev()

Signed-off-by: Borislav Petkov <bbpetkov@yahoo.de>


Index: 21-rc7/net/core/dev.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- 21-rc7.orig/net/core/dev.c
+++ 21-rc7/net/core/dev.c
@@ -3002,7 +3002,7 @@ out:
  *	chain. 0 is returned on success. A negative errno code is returned
  *	on a failure to set up the device, or if the name is a duplicate.
  *
- *	This is a wrapper around register_netdev that takes the rtnl semaphore
+ *	This is a wrapper around register_netdevice that takes the rtnl semapho=
re
  *	and expands the device name if you passed a format string to
  *	alloc_netdev.
  */
