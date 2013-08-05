From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Cluster-devel] [Patch net-next v2 6/8] fs: use generic union
 inet_addr and helper functions
Date: Mon, 05 Aug 2013 11:16:54 +0800
Message-ID: <1375672614.32485.9.camel@cr0>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-7-git-send-email-amwang@redhat.com>
	 <20130802103107.GA17244@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130802103107.GA17244-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-02 at 03:31 -0700, Christoph Hellwig wrote:
> On Fri, Aug 02, 2013 at 03:14:32PM +0800, Cong Wang wrote:
> > From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > 
> > nfs and cifs define some helper functions for sockaddr,
> > they can use the generic functions for union inet_addr too.
> > 
> > Since some dlm code needs to compare ->sin_port, introduce a
> > generic function inet_addr_equal_strict() for it.
> 
> Would sound more useful to have a sockaddr_equal case that can be used
> on any sockaddr.  For cases that no current user handles just return
> false.
> 

Ok, since you and other people ask for it.

Thanks.
