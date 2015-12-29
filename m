From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 16:19:21 +0300
Message-ID: <56828859.1020009@list.ru>
References: <5682665A.7090102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp53.i.mail.ru ([94.100.177.113]:40407 "EHLO smtp53.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbbL2NT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 08:19:29 -0500
In-Reply-To: <5682665A.7090102@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 13:54, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hello.
>=20
> I was hitting a strange problem when some internet hosts
> suddenly stops responding until I reboot. ping to these
> host gives "Destination Host Unreachable". After the
> initial confusion, I've finally got to
> ip route get
> and got something quite strange.
Another observation:


# ip route get 91.189.90.236
91.189.90.236 via 192.168.0.1 dev eth0  src 192.168.10.202
    cache <redirected>

# cat /proc/net/rt_cache
Iface	Destination	Gateway 	Flags		RefCnt	Use	Metric	Source		MTU	Window	=
IRTT	TOS	HHRef	HHUptod	SpecDst


So the redirection exists, but rt_cache doesn't show anything.
Am I looking in the wrong place? Where can I get a list of all
the redirections I have?
