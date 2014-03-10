From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCHv5 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Mon, 10 Mar 2014 13:01:33 -0500
Message-ID: <004101cf3c8a$c58d02e0$50a708a0$@opengridcomputing.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com> <20140310.133503.1268399872836123591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: "'David Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140310.133503.1268399872836123591.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> >    Dropped patch "cxgb4: use spinlock_irqsave/spinlock_irqrestore
for db
> lock".
> >    save/restore spinlock variants are not required - thanks to
review by
> >    David Miller.
> 
> That is absolutely not what I said.
> 
> I said that specific instances of the transformation were not correct,
> the rest were and were absolutely necessary.
> 

The remaining changes from the removed patch are moved into patch 10/31
(Doorbell Drop Avoidance Bug Fixes).  10/31 has the driver call
disable_txq_db() from an interrupt handler, and I thought it would be
better to put all the changes to fix how the db lock is acquired into
this one patch.   

We forgot mention this in the cover letter.  Sorry about that.

Steve.



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
