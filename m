From: Christoph Hellwig <hch@lst.de>
Subject: simplify configfs attributes V2
Date: Sat,  3 Oct 2015 15:32:36 +0200
Message-ID: <1443879179-22280-1-git-send-email-hch@lst.de>
Cc: Felipe Balbi <balbi@ti.com>,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series consolidates the code to implement configfs attributes
by providing the ->show and ->store method in common code and using
container_of in the methods to access the containing structure.

This reduces source and binary size of configfs consumers a lot.

Changes since V1:
 - a couple fixes for unintended changes in the uvc driver
 - moved a few CONFIG_ATTR() statements around
 - fixed up the documentation and samples in the last patch
 - added a little rather pointless blurb to the patch description for
   various patches
