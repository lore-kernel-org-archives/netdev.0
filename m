From: Michael Buesch <mb@bu3sch.de>
Subject: Please re-apply the pwork macsuspend patch
Date: Fri, 30 Jun 2006 19:38:08 +0200
Message-ID: <200606301938.08285.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59865
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932863AbWF3Ri3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:38:29 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please re-apply the "Suspend MAC in periodic work" now.
I neither remember the exact name, nor do I still have
the patch. Well, I deleted it since it was applied... hrm...
But I assume you know which patch I mean.

Please re-apply it because:
* It does _NO_ harm.
* It _fixes_ a bug.
* I am doing development which depends on this patch
  My development is stalled without the patch going
  into the tree. (Or at least it is a _lot_ more painful).
* It does _NO_ harm.
* Every "bug" or inconvenience (udelay), that Jeff saw, was
  not introduced by this patch. It was only in the _context_.
  In fact, that udelay loop has been there _forever_.

Thanks.

-- 
Greetings Michael.
