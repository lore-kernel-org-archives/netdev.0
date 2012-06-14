From: Thomas Graf <tgraf@suug.ch>
Subject: Re: =?utf-8?Q?include=2Fnet=2Fnetlink=2Eh?=
	=?utf-8?B?OjQ5Nzo0MTogd2FybmluZzog4oCYcmVwbHlfbmxo4oCZIG1h?=
	=?utf-8?Q?y?= be used uninitialized in this function
 [-Wuninitialized]
Date: Thu, 14 Jun 2012 04:30:57 -0400
Message-ID: <20120614083057.GA29738@canuck.infradead.org>
References: <4fd9474c.wdaRvq8n+Xh/6wOA%wfg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38357 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2FNIa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:30:58 -0400
Content-Disposition: inline
In-Reply-To: <4fd9474c.wdaRvq8n+Xh/6wOA%wfg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 10:07:08AM +0800, wfg@linux.intel.com wrote:
> FYI: there are new compile warnings show up in
>=20
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.=
git master
> head:   0450243096de90ff51c3a6c605410c5e28d79f8d
> commit: 33a03aadb52fa05d28aba6d8f0c03c7b3b905897 [464/472] dcbnl: Pre=
pare framework to shorten handling functions
> config: x86_64-randconfig-net3 (attached as .config)
>=20
> All related error/warning messages are:
>=20
> net/dcb/dcbnl.c: In function =E2=80=98dcb_doit=E2=80=99:
> include/net/netlink.h:497:41: warning: =E2=80=98reply_nlh=E2=80=99 ma=
y be used uninitialized in this function [-Wuninitialized]
> net/dcb/dcbnl.c:1975:19: note: =E2=80=98reply_nlh=E2=80=99 was declar=
ed here

gcc 4.6.3 on my system doesn't complain about this. I'm sending a patch=
=2E
