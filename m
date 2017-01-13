From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3 0/8] uapi: export all headers under uapi directories
Date: Fri, 13 Jan 2017 11:46:38 +0100
Message-ID: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
References: <3131144.4Ej3KFWRbz@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie,
 daniel.vetter@ffwll.ch, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
 sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-am33-list@redhat.com,
 linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org,
 linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux@armlinux.org.uk,
 hch@infradead.org, coreteam@netfilter.org, msalter@redhat.com,
 fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
 linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org,
 uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org,
 linux-kbuild@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
 linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org
To: arnd@arndb.de
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <3131144.4Ej3KFWRbz@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Here is the v3 of this series. The first 5 patches are just cleanup: some
exported headers were still under a non-uapi directory or (x86 case) were
wrongly exported.
The patch 6 was spotted by code review: there is no in-tree user of this
functionality.
Patches 7 and 8 remove the need to list explicitly headers. Now all files
under an uapi directory are exported.

This series has been tested with a 'make headers_install' on x86 and a
'make headers_install_all'. I've checked the result of both commands.

This patch is built against linus tree. If I must rebase it against the kbuild
tree, just tell me ;-)

v2 -> v3:
 - patch #1: remove arch/arm/include/asm/types.h
 - patch #2: remove arch/h8300/include/asm/bitsperlong.h
 - patch #3: remove arch/nios2/include/uapi/asm/setup.h
 - patch #4: don't export msr-index.h
 - patch #5: fix a typo: s/unput-files3-name/input-files3-name
 - patch #6: no change
 - patch #7: fix include/uapi/asm-generic/Kbuild.asm by introducing mandatory-y
 - add patch #8

v1 -> v2:
 - add patch #1 to #6
 - patch #7: remove use of header-y

Comments are welcomed,
Nicolas

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
