From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH -mm 3/10][RFC] aio: use iov_length instead of ki_left
Date: Tue, 16 Jan 2007 02:14:38 +0000
Message-ID: <20070116021438.GA15774@infradead.org>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com> <20070116015450.9764.52713.patchbomb.py@nate-64.agami.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nate Diller <nate.diller@gmail.com>, Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Suparna Bhattacharya <suparna@in.ibm.com>,
	Kenneth W Chen <kenneth.w.chen@intel.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <owner-linux-aio@kvack.org>
To: Nate Diller <nate@agami.com>
Content-Disposition: inline
In-Reply-To: <20070116015450.9764.52713.patchbomb.py@nate-64.agami.com>
Sender: owner-linux-aio@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 05:54:50PM -0800, Nate Diller wrote:
> Convert code using iocb->ki_left to use the more generic iov_length() call. 

No way.  We need to reduce the numer of iovec traversals, not adding
more of them.

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
