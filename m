From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: net/smc and the RDMA core
Date: Mon, 1 May 2017 18:33:11 +0200
Message-ID: <20170501163311.GA22209@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ursual, hi netdev reviewers,

how did the smc protocol manage to get merged without any review 
on linux-rdma at all?  As the results it seems it's very substandard
in terms of RDMA API usage, e.g. it neither uses the proper CQ API
nor the RDMA R/W API, and other will probably find additional issues
as well.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
