From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 06 Feb 2012 16:24:19 +0100
Message-ID: <1328541859.2220.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
	 <20120120.135028.1359677274445012541.davem@davemloft.net>
	 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
	 <20120204142823.GA7000@neilslaptop.think-freely.org>
	 <20120204155807.GA2657@nuttenaction>
	 <20120204200937.GA2670@neilslaptop.think-freely.org>
	 <20120205125325.GA31578@elastic.org>
	 <20120205191708.GA5337@neilslaptop.think-freely.org>
	 <20120205200428.GB2816@nuttenaction>
	 <20120206013247.GA5681@neilslaptop.think-freely.org>
	 <20120206152019.GG27935@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: "Frank Ch. Eigler" <fche@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57790 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab2BFPYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 10:24:23 -0500
Received: by wgbdt10 with SMTP id dt10so6333008wgb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 07:24:22 -0800 (PST)
In-Reply-To: <20120206152019.GG27935@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:20 -0500, Frank Ch. Eigler a =C3=
=A9crit :

> > [...] If something is needed in the short term for Satoru, I still
> > think a privately maintained module that registers a netfilter hook
> > to watch outgoing packets for retransmits offers a good solution.
>=20
> Does this mean that this netfilter hook mechanism is sufficient to
> adapt to the current/future diversity of behaviors?  Why not make
> *that* into a tracepoint then, so perf/stap scripts could get at it i=
n
> userspace?

Anyway, this netfilter module wont catch the failed retransmits (becaus=
e
of memory allocation errors or other checks done in our stack)
