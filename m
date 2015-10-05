From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: simplify configfs attributes V2
Date: Mon, 5 Oct 2015 14:37:05 -0700
Message-ID: <20151005143705.bdcfa7d7b8211506c5dbc12e@linux-foundation.org>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
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

On Sat,  3 Oct 2015 15:32:36 +0200 Christoph Hellwig <hch@lst.de> wrote:

> This series consolidates the code to implement configfs attributes
> by providing the ->show and ->store method in common code and using
> container_of in the methods to access the containing structure.
> 
> This reduces source and binary size of configfs consumers a lot.

There's a version of this patch series (I assume V1) in linux-next via
Nicholas's tree so my hands are tied.  I trust that Nicholas will
update things.

Or maybe it was a slipup - modifying usb, ocfs2 etc from the iscsi tree
is innovative ;)
