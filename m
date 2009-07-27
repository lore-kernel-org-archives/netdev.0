From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 10:09:24 +0200
Message-ID: <4A6D60B4.1070601@cosmosbay.com>
References: <4A6CA3BF.7010709@hartkopp.net> <200907270927.55728.remi.denis-courmont@nokia.com> <4A6D512A.1050504@gmail.com> <200907271106.02456.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?windows-1252?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42157 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZG0IJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 04:09:34 -0400
In-Reply-To: <200907271106.02456.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont a =E9crit :
> On Monday 27 July 2009 10:03:06 ext Eric Dumazet wrote:
>> R=E9mi Denis-Courmont a =E9crit :
>>> On Sunday 26 July 2009 21:43:11 ext Oliver Hartkopp wrote:
>>>> i got this build error from the latest net-next-2.6:
>>>>
>>>> net/phonet/pn_dev.c: In function =91phonet_init_net=92:
>>>> net/phonet/pn_dev.c:221: error: implicit declaration of function
>>>> =91proc_net_fops_create=92
>>>> net/phonet/pn_dev.c: In function =91phonet_exit_net=92:
>>>> net/phonet/pn_dev.c:242: error: implicit declaration of function
>>>> =91proc_net_remove=92
>>> Oops. This makes me wonder why I did not get that one here on my te=
st
>>> builds???
>> I also have this warning :
>>
>> net/phonet/pn_dev.c: In function `phonet_device_get':
>> net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized i=
n this
>> function
>=20
> Right. This is indeed a bug - thanks. Either my gcc version is bad at=
 that=20
> stuff or I have missing debug options :(
>=20

I currently use gcc-3.4.6, and current net-next-2.6 doesnt compile for =
me
(but linux-2.6 does compile properly so I just know this is already fix=
ed upstream)

  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o(.text+0x86b17): In function `igdng_compute_m_n':
: undefined reference to `__udivdi3'
drivers/built-in.o(.init.text+0x3c44): In function `con_init':
: undefined reference to `.L1443'
make: *** [.tmp_vmlinux1] Erreur 1

No problem with gcc-4.4.0=20
