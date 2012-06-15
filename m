From: Fengguang Wu <wfg@linux.intel.com>
Subject: Re: =?utf-8?Q?include=2Fnet=2Fnetlink=2Eh?=
 =?utf-8?B?OjQ5Nzo0MTogd2FybmluZzog4oCYcmVwbHlfbmxo4oCZIG1h?= =?utf-8?Q?y?=
 be used uninitialized in this function [-Wuninitialized]
Date: Fri, 15 Jun 2012 09:55:31 +0800
Message-ID: <20120615015531.GA8488@localhost>
References: <4fd9474c.wdaRvq8n+Xh/6wOA%wfg@linux.intel.com>
 <20120614083057.GA29738@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50466 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab2FOBzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 21:55:39 -0400
Content-Disposition: inline
In-Reply-To: <20120614083057.GA29738@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 04:30:57AM -0400, Thomas Graf wrote:
> On Thu, Jun 14, 2012 at 10:07:08AM +0800, wfg@linux.intel.com wrote:
> > FYI: there are new compile warnings show up in
> >=20
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-nex=
t.git master
> > head:   0450243096de90ff51c3a6c605410c5e28d79f8d
> > commit: 33a03aadb52fa05d28aba6d8f0c03c7b3b905897 [464/472] dcbnl: P=
repare framework to shorten handling functions
> > config: x86_64-randconfig-net3 (attached as .config)
> >=20
> > All related error/warning messages are:
> >=20
> > net/dcb/dcbnl.c: In function =E2=80=98dcb_doit=E2=80=99:
> > include/net/netlink.h:497:41: warning: =E2=80=98reply_nlh=E2=80=99 =
may be used uninitialized in this function [-Wuninitialized]
> > net/dcb/dcbnl.c:1975:19: note: =E2=80=98reply_nlh=E2=80=99 was decl=
ared here
>=20
> gcc 4.6.3 on my system doesn't complain about this. I'm sending a pat=
ch.

I'm running gcc 4.6.2 and will upgrade it.  Good to know gcc improved o=
n this!

Thanks,
=46engguang
