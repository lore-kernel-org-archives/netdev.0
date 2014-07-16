From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net-next 0/4] cxgb4i: Add ipv6 support
Date: Wed, 16 Jul 2014 08:32:59 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D854356F@nice.asicdesigners.com>
References: <1405479353-2289-1-git-send-email-anish@chelsio.com>,<20140716080849.GA29924@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org" <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>,
	"jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	SWise OGC <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140716080849.GA29924-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We don't have any specific changes queued for 3.17, but the next update 
requires a similar change to cxgb4. I'm okay submitting that to net-next if it
is okay with you. Plus one of the patches requires cxgb4 dcb code that is
not yet in the scsi tree.
-Anish
________________________________________
From: Christoph Hellwig [hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org]
Sent: Wednesday, July 16, 2014 1:08 AM
To: Anish Bhatt
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org; hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org; michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org; jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; Karen Xie; Casey Leedom; Hariprasad S; SWise OGC
Subject: Re: [PATCH net-next 0/4] cxgb4i: Add ipv6 support

Hi Anish,

the scsi side changes looks fine to me.  Unless you have major updates
to the scsi driver for 3.17 that could cause conflicts I'm fine with
merging the whole series in through the networking tree.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
