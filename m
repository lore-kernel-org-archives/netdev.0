From: Roland Dreier <roland@topspin.com>
Subject: [PATCH][v5][22/24] Document InfiniBand ioctl use
Date: Mon, 27 Dec 2004 21:51:19 -0800
Message-ID: <200412272151.zeKZJPoIEBr55elh@topspin.com>
References: <200412272151.3Lde9MPbD7ODIUdu@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <200412272151.3Lde9MPbD7ODIUdu@topspin.com>
To: davem@davemloft.net
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Add the 0x1b ioctl magic number used by ib_umad module to
Documentation/ioctl-number.txt.

Signed-off-by: Roland Dreier <roland@topspin.com>


--- linux-bk.orig/Documentation/ioctl-number.txt	2004-12-27 21:47:59.407053483 -0800
+++ linux-bk/Documentation/ioctl-number.txt	2004-12-27 21:48:28.036839302 -0800
@@ -72,6 +72,7 @@
 0x09	all	linux/md.h
 0x12	all	linux/fs.h
 		linux/blkpg.h
+0x1b	all	InfiniBand Subsystem	<http://www.openib.org/>
 0x20	all	drivers/cdrom/cm206.h
 0x22	all	scsi/sg.h
 '#'	00-3F	IEEE 1394 Subsystem	Block for the entire subsystem
