From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [Patch net-next v3 7/9] fs: use generic union inet_addr and
 helper functions
Date: Mon, 19 Aug 2013 07:37:52 -0700
Message-ID: <20130819143752.GA12266@infradead.org>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
 <1376907278-26377-8-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Christine Caulfield <ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Teigland <teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1376907278-26377-8-git-send-email-amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> @@ -1900,17 +1901,9 @@ srcip_matches(struct sockaddr *srcaddr, struct sockaddr *rhs)
>  {

I think your new sockaddr_equal should be equivalent to to this
srcip_matches, that is it should warn about and return false for unknown
address families.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
