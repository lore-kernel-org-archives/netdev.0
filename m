From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: IPv6 kernel ooops
Date: Sun, 25 Apr 2004 10:42:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040425.104217.31070133.yoshfuji@wide.ad.jp>
References: <20040424222340.GA10595@binhex.EU.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gdh@binhex.EU.org
In-Reply-To: <20040424222340.GA10595@binhex.EU.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040424222340.GA10595@binhex.EU.org> (at Sat, 24 Apr 2004 22=
:23:41 +0000), Gu=F0mundur D. Haraldsson <gdh@binhex.EU.org> says:

> I got this oops on my machine tonight.
>
> I don't know what query to BIND caused it, but I've got an oops like th=
is before!

Is this reproducable? How frequently do you see this?


> Call Trace:   [<c02112f0>] output_maybe_reroute [kernel] 0x0 (0xc39d9d0=
c)

(Umm, I cannot find "output_maybe_reroute" in my source...)

> [<c68e2df1>] udpv6_sendmsg [ipv6] 0x271 (0xc39d9d3c)
> [<c68e2a90>] udpv6_getfrag [ipv6] 0x0 (0xc39d9d44)
:

Would you test latest rc (or bk tree), please?

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
