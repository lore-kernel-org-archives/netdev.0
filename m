From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 07:38:54 -0700
Message-ID: <20160407143854.GA7685@infradead.org>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Tom Herbert <tom@herbertland.com>,
	lsf-pc@lists.linux-foundation.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160407161715.52635cac@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This is also very interesting for storage targets, which face the same
issue.  SCST has a mode where it caches some fully constructed SGLs,
which is probably very similar to what NICs want to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
