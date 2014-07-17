From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] libcxgbi: Add ipv6 api to driver
Date: Wed, 16 Jul 2014 23:23:55 -0700 (PDT)
Message-ID: <20140716.232355.1673092200124116952.davem@davemloft.net>
References: <1405479353-2289-1-git-send-email-anish@chelsio.com>
	<1405479353-2289-4-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, manojmalviya-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405479353-2289-4-git-send-email-anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Tue, 15 Jul 2014 19:55:52 -0700

> +#define pr_info_ipaddr(fmt_trail,					\
> +			addr1, addr2, args_trail...)			\

Barf... use "%pIS" instead, which takes a pointer to a sockaddr of family
AF_INET or AF_INET6.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
