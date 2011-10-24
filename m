From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 07/10] RDMA/cxgb4: DB Drop Recovery for RDMA and LLD queues.
Date: Mon, 24 Oct 2011 20:46:31 +0530
Message-ID: <4EA5814F.6080801@chelsio.com>
References: <4EA030F5.3000007@opengridcomputing.com> <CAL1RGDUDk_MAM+S+MaEcPQzug8TvE-mFAfNqX3FqRApLQu9H2g@mail.gmail.com> <4EA05A27.9090605@opengridcomputing.com> <20111020.165703.1713724038045504243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111020.165703.1713724038045504243.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 21-10-2011 02:27, David Miller wrote:

> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> Date: Thu, 20 Oct 2011 12:28:07 -0500
> 
>> On 10/20/2011 12:17 PM, Roland Dreier wrote:
>>>> I believe 5 and 7 have build dependencies.
>>> Right, missed that one too.
>>>
>>> But it seems 4,6,8,9,10 are independent of the rest of the series?
>>>
>>> ie I can trivially apply them and then worry about working out
>>> the drivers/net / drivers/infiniband interdependency a bit later?
>>>
>>
>> Some of these might be dependent on prior patches the series.  But if
>> they aren't, yes, you could do that.
> 
> So, how do you guys want to do this?  If you give me a list of which
> patches I should put into net-next and leave the rest to the infiniband
> tree, that'd work fine for me as long as net-next is left in a working
> state independent of the infiniband tree.


Hi Dave Miller/Roland,

With respect to above dependencies we did some experiments and found
following things

1. We can apply three cxgb4 patches, 01 02 and 03, on net-next tree
successfully and build it.

2. Out of 7 RDMA/cxgb4 patches only 04, 08 and 10 can be applied
trivially and driver can be built successfully. If we try to apply
remaining patches, 05 06 07 and 09, either they will fail to apply or
give build failure. Moreover patches 05, 06, 07 and 09 can be applied on
top of 04, 08 and 10 cleanly.

Based on above results we would like to propose following two things.

1. We would like to recommend that all the patches get included in
Roland's infiniband tree since it has build dependencies.

2. Alternatively,
- Patches 01, 02 and 03 can be included in net-next tree.
- Patches 04, 08 and 10 can be included in Roland's infiniband tree at
present.
- Patches 05, 06, 07 and 09 have to wait till the net-next hits the
3.2-rc1.

Please let us know if you have any other suggestions.

Thanks,
Vipul
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
