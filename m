From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH -mm 2/10][RFC] aio: net use struct socket for io
Date: Mon, 15 Jan 2007 21:44:27 -0800
Message-ID: <20070115214427.7fc55a6c@oldman>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com>
	<20070116015450.9764.24404.patchbomb.py@nate-64.agami.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Nate Diller <nate@agami.com>
In-Reply-To: <20070116015450.9764.24404.patchbomb.py@nate-64.agami.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jan 2007 17:54:50 -0800
Nate Diller <nate@agami.com> wrote:

> Remove unused arg from socket operations
> 
> The sendmsg and recvmsg socket operations take a kiocb pointer, but none of
> the functions actually use it.  There's really no need even theoretically,
> it's really quite ugly having it there at all.  Also, removing it will pave
> the way for a more generic completion path in the file_operations.
> 
> ---

Would getting rid of these make later implementation of AIO networking
harder?
