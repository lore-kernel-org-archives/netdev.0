From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH net-next] qed*: Utilize Firmware 8.15.3.0
Date: Thu, 9 Mar 2017 13:45:57 -0800
Message-ID: <20170309214557.GA16860@infradead.org>
References: <1489091851-1282-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Tomer Tayar <Tomer.Tayar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Manish Rangankar <Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Chad Dupuis <Chad.Dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489091851-1282-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We can't just require a new firmware version in the driver, as
users most likely won't have it by the time they install the new
kernel.  So you'll have to support the old firmware version as well.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
