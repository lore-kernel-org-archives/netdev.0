From: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 11:59:35 -0800
Message-ID: <DB7B3A5C-9674-44C2-8AA4-2C468F09DFF5@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com> <20140304.132226.75524344104026791.davem@davemloft.net> <20140305053024.GA23862@hariprasad-pc> <9E6E5D92-7F25-49A3-BEB5-424CCE2F725D@chelsio.com> <CAJZOPZL05TY6qSdBDoS6aCj=_uepkZTX5+fVvnHTsCsKKMqgSQ@mail.gmail.com> <F598A76E-C6C1-4183-B4B9-DF78FD1FE73A@chelsio.com> <CAJZOPZL6U7csoTvF8wzJBK+Whknv4dqNbkO8nC=LrXoUMXhoUQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZL6U7csoTvF8wzJBK+Whknv4dqNbkO8nC=LrXoUMXhoUQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Mar 5, 2014, at 11:52 AM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Wed, Mar 5, 2014 at 9:46 PM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wro=
te:
>> On Mar 5, 2014, at 11:39 AM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote=
:
>>> On Wed, Mar 5, 2014 at 9:15 PM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> w=
rote:
>>>> Yes, thanks mightily for your help and advice and sorry for the si=
ze of the updates.  Hari has taken on the very difficult task of synchr=
onizing our out-of-kernel development branch with the in-kernel code.  =
These two code bases have drifted apart quite a bit because of the diff=
iculty of translating our out-of-kernel changes into the in-kernel driv=
er which uses completely different symbolic register constants.
>>>=20
>>> Can you explain this in a little bit more details? what's the sourc=
e
>>> of the need to use two different sets of symbolic register constant=
s?
>>=20
>>  When our cxgb4 driver was first submitted for inclusion in kernel.o=
rg someone objected to the format of our symbolic register constants an=
d forced us to change them.
>=20
> are you referring to constants defined in
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.h or other/more headers?

  t4_regs.h.  Strangely, when we submitted the driver, the very similar=
 symbolic constant formats in t4_msg.h and t4fw_api.h weren=92t targete=
d; just the ones in t4_regs.h.

Casey

> Unfortunately these constants are generated directly from our hardwar=
e
> design and we can't change them internally -- it would significantly
> increase development/debugging time with our hardware team if we had
> to constantly help the hardware team member translate back and forth
> between the confusingly similar but different names.  Additionally,
> though I know that this isn't a concern of kernel.org, every other OS
> driver for our adapters use the hardware-derived symbolic register
> constants and our software team internally often work on several
> different OS Drivers as we work out better ways to do various things.
> All of this means that our in-house/out-of-kernel driver uses the
> hardware-derived symbolic constants and every time we need to push a
> change into kernel.org we need to go through a very careful
> translation of the symbolic register constants.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
