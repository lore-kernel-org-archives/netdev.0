From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 2 Dec 2010 05:42:00 -0500
Message-ID: <20101202104200.GD10221@canuck.infradead.org>
References: <4CF71ADB.5060702@cn.fujitsu.com>
 <20101202095753.GA10221@canuck.infradead.org>
 <4CF77686.5010305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:52070 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab0LBKmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 05:42:02 -0500
Content-Disposition: inline
In-Reply-To: <4CF77686.5010305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 02, 2010 at 06:35:50PM +0800, Shan Wei wrote:
> Thomas Graf wrote, at 12/02/2010 05:57 PM:
> >>  /* ICMP */
> >>  #define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
> >> -#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
> >> -
> >> +#define ICMP_MIB_MAX	__ICMP_MIB_MAX
> >=20
> > Looks like the +1 is there to account for ICMP_MIB_DUMMY. It is
> > unused though but you have to remove it as well if you want to
> > kill that extra +1.
>=20
> I don't know the history about ICMP_MIB_DUMMY before v2.6.12-rc2.=20
> But after that, it is abandoned.
>=20
> ICMP_MIB_DUMMY is killed in patch:
> =EF=BC=BBPATCH v2 4/4] net: kill unused macros from head file

OK, fair enough. Wasn't obvious while reviewing this patch.
