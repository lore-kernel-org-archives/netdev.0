From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: simplify configfs attributes V2
Date: Tue, 13 Oct 2015 22:23:13 -0700
Message-ID: <1444800193.18065.12.camel@haakon3.risingtidesystems.com>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christoph & Co,

On Sat, 2015-10-03 at 15:32 +0200, Christoph Hellwig wrote:
> This series consolidates the code to implement configfs attributes
> by providing the ->show and ->store method in common code and using
> container_of in the methods to access the containing structure.
> 
> This reduces source and binary size of configfs consumers a lot.
> 
> Changes since V1:
>  - a couple fixes for unintended changes in the uvc driver
>  - moved a few CONFIG_ATTR() statements around
>  - fixed up the documentation and samples in the last patch
>  - added a little rather pointless blurb to the patch description for
>    various patches
> 

Apologies for the delayed follow-up on -v2.

Applied to target-pending/for-next, with Felipe's ACK for usb, and
Pratyush's ACK for spear13xx.

Thank you,

--nab
