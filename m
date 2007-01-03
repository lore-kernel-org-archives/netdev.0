From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'qla3xxx-upstream-fixes-20070103-00' tag
Date: Wed, 3 Jan 2007 23:36:53 +0100
Message-ID: <20070103223653.GA10018@electric-eye.fr.zoreil.com>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org> <45919563.9030304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39680 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164AbXACWjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 17:39:22 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45919563.9030304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from tag 'qla3xxx-upstream-fixes-20070103-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git tag qla3xxx-upstream-fixes-20070103-00

to get the changes below.

Distance from 'netdev-2.6-upstream-fixes'
-----------------------------------------

736272c636cea8593e0907a8c44ec411710c06c1
81f4e6c190a0fa016fd7eecaf76a5f95d121afc2 <- netdev-2.6-upstrem-fixes

Diffstat
--------

 drivers/net/qla3xxx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

Shortlog
--------

Ron Mercer:
      qla3xxx: Remove NETIF_F_LLTX from driver features

Patch
-----

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d79d141..36e0830 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3370,7 +3370,6 @@ static int __devinit ql3xxx_probe(struct
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	ndev->features = NETIF_F_LLTX;
 	if (pci_using_dac)
 		ndev->features |= NETIF_F_HIGHDMA;
 
--- 
Regarding:

Jeff Garzik <jeff@garzik.org> :
> Ron Mercer wrote:
> >These 5 patches were submitted on Dec 5th (1&2) and Dec 11th (3-5).  They 
> >add/fix the following
> >
> >1. Add support for Qlogic 4032 chip.
> >2. Change minor version for 4032 support.
> >3. Add delay when accessing NVRAM.
> >4. Remove NETIF_F_LLTX flag from features.  It was left over from the 
> >early driver and shouldn't be there.
> >5. Fix rx checksum warning.
[...]
> 2) Re-order the patches so that bug fixes come first.  Otherwise this 
> entire patchset must go into netdev-2.6.git#upstream, because patch #1 
> is not a bug fix and we are in a bug-fixes-only cycle.

Patch #5 fixes #1. Both can be merged and actually are in the 'qla3xxx' branch
at git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git. This branch is
against plain Linus's 'master'. The serie is not ready for submission yet but
the very first patches match Ron's ones.

-- 
Ueimor
