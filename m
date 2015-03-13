From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Fri, 13 Mar 2015 16:37:07 +0000
Message-ID: <20150313163707.GP29656@ZenIV.linux.org.uk>
References: <20150313131543.7c050492@canb.auug.org.au>
 <20150312.232426.1464986797003264151.davem@davemloft.net>
 <20150313035609.GO29656@ZenIV.linux.org.uk>
 <20150313153817.34510752@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@lst.de, ying.xue@windriver.com,
	Felipe Balbi <balbi@ti.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-usb@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150313153817.34510752@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 13, 2015 at 03:38:17PM +1100, Stephen Rothwell wrote:

> There is also a conflict with e9eab93cc2dc ("fs: don't allow to
> complete sync iocbs through aio_complete"), though it doesn't show up
> in the resolution since I I just used the next-next tree bits.  So a
> common branch containing that as well could be merged into both trees.

OK, for now I've done just that (vfs.git#iocb in never-rebase mode).
I still think that vfs.git#gadget ought to go into mainline; arguments
for the rest of #iocb are weaker and merging it into net-next would
suffice; as the matter of fact, I have pending stuff for net-next touching
the same area (further reduction of ->sendmsg()/->recvmsg() argument lists;
total_len is redundant); might as well deal with that when feeding that
to Dave...
