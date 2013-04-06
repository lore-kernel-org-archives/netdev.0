From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Sat, 06 Apr 2013 12:56:52 +0800
Message-ID: <515FAB14.1020909@asianux.com>
References: <1364999477.13853.21.camel@edumazet-glaptop>  <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>  <515D3A09.7040202@asianux.com>  <20130404.140956.2233513394092413594.davem@davemloft.net>  <1365130824.25884.8.camel@joe-AO722> <1365194247.22273.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	mkubecek@suse.cz, fengguang.wu@intel.com, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:47234 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3DFE51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 00:57:27 -0400
In-Reply-To: <1365194247.22273.7.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=C4=EA04=D4=C206=C8=D5 04:37, Dan Williams wrote:
> On Thu, 2013-04-04 at 20:00 -0700, Joe Perches wrote:
>> > On Thu, 2013-04-04 at 14:09 -0400, David Miller wrote:
>>> > > From: Chen Gang <gang.chen@asianux.com>
>>> > > Date: Thu, 04 Apr 2013 16:30:01 +0800
>>>>> > > >> Of course, nobody sane actually cares about ISDN any more,=
 so I think
>>>>> > > >> this is all pretty academic. I think even Germany (where I=
SDN *used*
>>>>> > > >> to be very common due to telephone monopolies and odd rule=
s) no longer
>>>>> > > >> uses it. I can't imagine that anybody else does either.
>>>> > > >   can we delete it ?
>>> > > I think the point is no that we can delete it, but rather that =
we
>>> > > should concentrate our efforts on code that more people use rat=
her
>>> > > than trying to clean up antiquated code with very few users.
>> >=20
>> > Very sensible.
>> >=20
>> > I was going to see about moving drivers/isdn/hardware/eicon
>> > to staging but it seems the hardware is still for sale.
>> >=20
>> > http://www.dialogic.com/en/products/media/diva/diva-bri-2.aspx
>> >=20
>> > Anyone have suggestions on other obsolete isdn drivers that
>> > could be moved to staging for awhile before deletion?
> Anything PCMCIA or ISA?  There are a number of them:
>=20
> CONFIG_ISDN_DRV_AVMB1_B1ISA
> CONFIG_ISDN_DRV_AVMB1_B1PCMCIA
> CONFIG_ISDN_DRV_AVMB1_AVM_CS
> CONFIG_ISDN_DRV_AVMB1_T1ISA
> CONFIG_HISAX_SEDLBAUER_CS
> CONFIG_HISAX_ELSA_CS
> CONFIG_HISAX_AVM_A1_CS
> CONFIG_HISAX_TELES_CS
> CONFIG_ISDN_DRV_ACT2000
>=20
> That's all I can find in a quick look.

  thanks. it seems we really can not delete ISDN.

  :-)

--=20
Chen Gang

Asianux Corporation
