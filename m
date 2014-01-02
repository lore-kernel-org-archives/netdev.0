From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 11:42:46 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1401021140220.2182@localhost6.localdomain6>
References: <52C4BD16.5010702@huawei.com> <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6> <52C52180.2030707@huawei.com> <alpine.DEB.2.02.1401020937490.2182@localhost6.localdomain6> <52C52AAD.8040603@huawei.com> <alpine.DEB.2.02.1401021011400.2182@localhost6.localdomain6>
 <52C53EC6.30902@huawei.com> <52C541A9.8060002@huawei.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-227853327-1388659368=:2182"
Cc: Julia Lawall <julia.lawall@lip6.fr>, Joe Perches <joe@perches.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C541A9.8060002@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-227853327-1388659368=:2182
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 2 Jan 2014, Ding Tianhong wrote:

> On 2014/1/2 18:26, Ding Tianhong wrote:
> > On 2014/1/2 17:14, Julia Lawall wrote:
> >> On Thu, 2 Jan 2014, Ding Tianhong wrote:
> >>
> >>> On 2014/1/2 16:38, Julia Lawall wrote:
> >>>> On Thu, 2 Jan 2014, Ding Tianhong wrote:
> >>>>
> >>>>> On 2014/1/2 15:39, Julia Lawall wrote:
> >>>>>> Are the casts needed
> >>>>>
> >>>>>
> >>>>> Yes, otherwise the warming will report:
> >>>>>
> >>>>> /net-next/drivers/net/bonding/bond_3ad.c:427: warning: passing argument 1 of ‘ether_addr_equal_64bits’ from incompatible pointer type
> >>>>
> >>>> Is it necessary for this driver to use a different type from everyone 
> >>>> else?
> >>>>
> >>>> julia
> >>>>
> >>> Did you mean the MAC_ADDRESS_EQUAL is excess?
> >>> I did not remove it because the codes no need to be changed more and it looks that didn't take any negative effect.
> >>
> >> No, I was wondering about the mac_addr type, defined in bond_3ad.h.  Other 
> >> code just has the array inlined into the containing structure.
> >>
> >> julia
> >>
> 
> I reviewed the struct mac_addr again, and feel that even it looks not comfortable, but
> make the lacp struct more meaning for 3ad, what do you think about it, I think no need
> to revert them to u8.

Personally, when I see things that are different, I start wondering about 
why.  So if there is no reason for it to be different, I would prefer that 
it is the same.

Certainly, a mac_addr type is more meaningful than just an array with size 
ETH_ALEN, or worse an array with size 6.  But I am not sure that it is 
practical to introduce that type everywhere.

In any case, it is not a big issue.

julia
--8323328-227853327-1388659368=:2182--
