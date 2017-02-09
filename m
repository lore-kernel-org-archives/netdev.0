From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv4 net-next 0/7] net: dst_confirm replacement
Date: Thu, 09 Feb 2017 17:02:08 -0500 (EST)
Message-ID: <20170209.170208.999235350231796696.davem@davemloft.net>
References: <1486415657-14714-1-git-send-email-ja@ssi.bg>
        <20170207.131134.567606043153504044.davem@davemloft.net>
        <alpine.LFD.2.11.1702082245270.2608@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuehaibing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: ja-FgGsKACvmQM@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.11.1702082245270.2608-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Date: Wed, 8 Feb 2017 23:05:36 +0200 (EET)

> On Tue, 7 Feb 2017, David Miller wrote:
> 
>> > - Now may be old function neigh_output() should be restored
>> > instead of dst_neigh_output?
>> 
>> Please elaborate.
> 
> 	As dst_neigh_output does not use the dst arg anymore,
> my idea was to rename dst_neigh_output to neigh_output, i.e.
> just like it was before commit 5110effee8fd ("net: Do delayed neigh 
> confirmation."

This sounds like a great idea.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
