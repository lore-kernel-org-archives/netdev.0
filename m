From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Cluster-devel] [Patch net-next v2 6/8] fs: use generic union
 inet_addr and helper functions
Date: Fri, 2 Aug 2013 03:31:07 -0700
Message-ID: <20130802103107.GA17244@infradead.org>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
 <1375427674-21735-7-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, cluster-devel@redhat.com,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375427674-21735-7-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 02, 2013 at 03:14:32PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> nfs and cifs define some helper functions for sockaddr,
> they can use the generic functions for union inet_addr too.
> 
> Since some dlm code needs to compare ->sin_port, introduce a
> generic function inet_addr_equal_strict() for it.

Would sound more useful to have a sockaddr_equal case that can be used
on any sockaddr.  For cases that no current user handles just return
false.
