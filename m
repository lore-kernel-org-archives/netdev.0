From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Thu, 13 Jan 2011 12:28:56 -0800 (PST)
Message-ID: <20110113.122856.112848917.davem@davemloft.net>
References: <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com>
	<20110113100224.GB30432@canuck.infradead.org>
	<AANLkTi=jRKjxCJ+LitX5TaqxWakj39DM37hGUw_rJG4H@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	opurdila@ixiacom.com, ddvlad@rosedu.org
To: lucian.grijincu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756822Ab1AMU2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 15:28:24 -0500
In-Reply-To: <AANLkTi=jRKjxCJ+LitX5TaqxWakj39DM37hGUw_rJG4H@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Thu, 13 Jan 2011 14:23:41 +0200

> On Thu, Jan 13, 2011 at 12:02 PM, Thomas Graf <tgraf@infradead.org> wrote:
>> On Thu, Jan 13, 2011 at 09:50:14AM +0200, Lucian Adrian Grijincu wrote:
>>> Yes it works, but there does not seem to be a good reason why to
>>> complicate things like this (again the sentinel nature of zero is not
>>> used in any place here).
>>
>> I have no objects to changing this at all but we don't gain much either.
> 
> 
> Should I post a new patch in which IFLA_INET_CONF cfgid values start
> from 0 also or must the ABI for libnl be kept as-is (counting from 1)?

I think the conclusion is that we won't apply your change, sorry.

There is almost zero upside, and one known downside in that we have
to deal with this user visible breakage somehow.
