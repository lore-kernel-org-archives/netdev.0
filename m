From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv2 net-next 0/3] RDMA/cxgb4,cxgb4vf,cxgb4i,csiostor:
 Cleanup macros
Date: Wed, 05 Nov 2014 14:54:43 -0500 (EST)
Message-ID: <20141105.145443.897956918105740779.davem@davemloft.net>
References: <1415069457-22277-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415069457-22277-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Tue,  4 Nov 2014 08:20:54 +0530

> It's not really the "hardware" which generates these hardware constant symbolic
> macros/register defines of course, it's scripts developed by the hardware team.
> Various patches have ended up changing the style of the symbolic macros/register
> defines and some of them used the macros/register defines that matches the
> output of the script from the hardware team.

We've told you that we don't care what format your internal whatever uses
for these macros.

We have standards, tastes, and desires and reasons for naming macros
in a certain way in upstream kernel code.

I consider it flat out unacceptable to use macros with one letter
prefixes like "S_".  You simply should not do this.

Why?

Because you are polluting the global name space, that's why.

You should only define macros with very-likely-to-be-unique prefixes
otherwise you and some arch/* header file are going to define the same
thing.

This is not just theory, it has happened in the past.

I'm not applying this series, fixup your macros properly.  And to
repeat, complaints about how your internal tools generate things
will fall on deaf ears.

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
