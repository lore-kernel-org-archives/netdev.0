From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 07/10] RDMA/cxgb4: DB Drop Recovery for RDMA and LLD
 queues.
Date: Thu, 20 Oct 2011 16:57:03 -0400 (EDT)
Message-ID: <20111020.165703.1713724038045504243.davem@davemloft.net>
References: <4EA030F5.3000007@opengridcomputing.com>
	<CAL1RGDUDk_MAM+S+MaEcPQzug8TvE-mFAfNqX3FqRApLQu9H2g@mail.gmail.com>
	<4EA05A27.9090605@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EA05A27.9090605-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Date: Thu, 20 Oct 2011 12:28:07 -0500

> On 10/20/2011 12:17 PM, Roland Dreier wrote:
>>> I believe 5 and 7 have build dependencies.
>> Right, missed that one too.
>>
>> But it seems 4,6,8,9,10 are independent of the rest of the series?
>>
>> ie I can trivially apply them and then worry about working out
>> the drivers/net / drivers/infiniband interdependency a bit later?
>>
> 
> Some of these might be dependent on prior patches the series.  But if
> they aren't, yes, you could do that.

So, how do you guys want to do this?  If you give me a list of which
patches I should put into net-next and leave the rest to the infiniband
tree, that'd work fine for me as long as net-next is left in a working
state independent of the infiniband tree.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
