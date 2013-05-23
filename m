From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: ethernet: sun: drop unused variable
Date: Thu, 23 May 2013 12:13:29 -0700 (PDT)
Message-ID: <20130523.121329.781995429475451805.davem@davemloft.net>
References: <1369267057-9371-3-git-send-email-emilio@elopez.com.ar>
	<20130522.234318.1664796969540142910.davem@davemloft.net>
	<519E117F.9040707@elopez.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: emilio@elopez.com.ar
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519E117F.9040707@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Emilio L=F3pez <emilio@elopez.com.ar>
Date: Thu, 23 May 2013 09:54:23 -0300

> Hi David,
>=20
> El 23/05/13 03:43, David Miller escribi=F3:
>> From: Emilio L=F3pez <emilio@elopez.com.ar>
>> Date: Wed, 22 May 2013 20:57:37 -0300
>>=20
>>> Commit bfd428d ("net: ethernet: sun: initialize variables directly"=
)
>>> dropped the only loop that was using i but did not remove the actua=
l
>>> variable, therefore causing a warning when building. This patch dro=
ps
>>> the now redundant line.
>>>
>>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>>> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>
>>=20
>> Applied.
>=20
> I see that you applied the series in net instead of net-next; the
> previous patches were in net-next only. This will cause build breakag=
e
> in net because the loop is still there.

My bad, I'll fix this up.
