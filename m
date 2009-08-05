From: =?UTF-8?B?Q2hpYS1jaGkgWWVoICjokYnlrrbpvYop?= <chiachi@android.com>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
	ipi_ifindex = 0
Date: Wed, 5 Aug 2009 08:06:25 +0800
Message-ID: <6c039e090908041706p6f06ac55ja796ac53855e829a@mail.gmail.com>
References: <1248912621.13447.12.camel@merlyn>
	 <20090803.212323.256579233.davem@davemloft.net>
	 <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
	 <20090804.115701.250978139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933835AbZHEAG0@vger.kernel.org>
In-Reply-To: <20090804.115701.250978139.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/8/5 David Miller <davem@davemloft.net>:
> I think we really cannot change behavior here. =A0If the user specifi=
es
> "0" in ipi_ifindex we must respect that in ipc->oif. =A0This is an
> override, and the ability to override is the very purpose of this
> control message.
>
> Even GLIBC makes use of that case of specifying "0" in ipi_ifindex.
> We must respect it.
>
> I'm not applying any of these patches, sorry.
>

If you treat ipi_ifindex as an override, do you want to do that in
ipi6_ifindex as well? Also, CAP_NET_RAW check for SO_BINDTODEVICE
becomes meaningless in this case.

I did not find the usage of ipi_ifindex in glibc. It would be great if
you can give me some pointers. Thanks for your help.

Chia-chi
