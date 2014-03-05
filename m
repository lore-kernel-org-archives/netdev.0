From: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 11:46:22 -0800
Message-ID: <F598A76E-C6C1-4183-B4B9-DF78FD1FE73A@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com> <20140304.132226.75524344104026791.davem@davemloft.net> <20140305053024.GA23862@hariprasad-pc> <9E6E5D92-7F25-49A3-BEB5-424CCE2F725D@chelsio.com> <CAJZOPZL05TY6qSdBDoS6aCj=_uepkZTX5+fVvnHTsCsKKMqgSQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZL05TY6qSdBDoS6aCj=_uepkZTX5+fVvnHTsCsKKMqgSQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Mar 5, 2014, at 11:39 AM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Wed, Mar 5, 2014 at 9:15 PM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wro=
te:
>>  Yes, thanks mightily for your help and advice and sorry for the siz=
e of the updates.  Hari has taken on the very difficult task of synchro=
nizing our out-of-kernel development branch with the in-kernel code.  T=
hese two code bases have drifted apart quite a bit because of the diffi=
culty of translating our out-of-kernel changes into the in-kernel drive=
r which uses completely different symbolic register constants.
>=20
> Can you explain this in a little bit more details? what's the source
> of the need to use two different sets of symbolic register constants?

  When our cxgb4 driver was first submitted for inclusion in kernel.org=
 someone objected to the format of our symbolic register constants and =
forced us to change them.  Unfortunately these constants are generated =
directly from our hardware design and we can=92t change them internally=
 =97 it would significantly increase development/debugging time with ou=
r hardware team if we had to constantly help the hardware team member t=
ranslate back and forth between the confusingly similar but different n=
ames.  Additionally, though I know that this isn=92t a concern of kerne=
l.org, every other OS driver for our adapters use the hardware-derived =
symbolic register constants and our software team internally often work=
 on several different OS Drivers as we work out better ways to do vario=
us things.  All of this means that our in-house/out-of-kernel driver us=
es the hardware-derived symbolic constants and every time we need to pu=
sh a change into kernel.org we need to go through a very careful transl=
ation of the symbolic register constants.

Casey

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
