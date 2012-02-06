From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 10:38:07 -0500
Message-ID: <20120206153807.GA3620@hmsreliant.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
 <20120205125325.GA31578@elastic.org>
 <20120205191708.GA5337@neilslaptop.think-freely.org>
 <20120205200428.GB2816@nuttenaction>
 <20120206013247.GA5681@neilslaptop.think-freely.org>
 <20120206152019.GG27935@redhat.com>
 <1328541859.2220.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Frank Ch. Eigler" <fche@redhat.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35802 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755300Ab2BFPig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 10:38:36 -0500
Content-Disposition: inline
In-Reply-To: <1328541859.2220.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2012 at 04:24:19PM +0100, Eric Dumazet wrote:
> Le lundi 06 f=E9vrier 2012 =E0 10:20 -0500, Frank Ch. Eigler a =E9cri=
t :
>=20
> > > [...] If something is needed in the short term for Satoru, I stil=
l
> > > think a privately maintained module that registers a netfilter ho=
ok
> > > to watch outgoing packets for retransmits offers a good solution.
> >=20
> > Does this mean that this netfilter hook mechanism is sufficient to
> > adapt to the current/future diversity of behaviors?  Why not make
> > *that* into a tracepoint then, so perf/stap scripts could get at it=
 in
> > userspace?
>=20
> Anyway, this netfilter module wont catch the failed retransmits (beca=
use
> of memory allocation errors or other checks done in our stack)
>=20
But the existing kfree_skb tracepoint will.  As will the TCPRETANSFAIL =
counter.
