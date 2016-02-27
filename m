From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: net/9p: convert to new CQ API
Date: Sat, 27 Feb 2016 10:25:50 +0100
Message-ID: <1456565151-27115-1-git-send-email-hch@lst.de>
To: v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

who is maintaining the "RDMA transport" (1) for 9p?  Below patch converts
it to your new CQ API.  It's fairly trivial, but untested as I can't figure
out how to actually test this code.

[1] RDMA seems a bit of a misowner as it's never doing RDMA data transfers,
but that's a separate story :)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
