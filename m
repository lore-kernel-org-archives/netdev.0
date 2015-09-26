From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: simplify configfs attributes
Date: Sat, 26 Sep 2015 16:49:06 -0700
Message-ID: <1443311346.7042.35.camel@haakon3.risingtidesystems.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1443189000-13398-1-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-09-25 at 06:49 -0700, Christoph Hellwig wrote:
> This series consolidates the code to implement configfs attributes
> by providing the ->show and ->store method in common code and using
> container_of in the methods to access the containing structure.
> 
> This reduces source and binary size of configfs consumers a lot.
> 

Looking at the complete series, the subsystem it touches the most is
target-core + fabric driver code, which is not surprising considering
it's the largest consumer of configfs.

That said, it would probably make sense to merge via target-pending.git
and get this series into linux-next ASAP.

--nab
