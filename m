From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Thu, 13 Jan 2011 05:02:24 -0500
Message-ID: <20110113100224.GB30432@canuck.infradead.org>
References: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com>
 <20110112.184734.38051229.davem@davemloft.net>
 <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, opurdila@ixiacom.com,
	ddvlad@rosedu.org
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:43454 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab1AMKCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 05:02:32 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 09:50:14AM +0200, Lucian Adrian Grijincu wrote:
> Yes it works, but there does not seem to be a good reason why to
> complicate things like this (again the sentinel nature of zero is not
> used in any place here).

The reason I didn't change anything was the same as Dave's reply, I
thought it must have been done on purpose. It probably was but I can't
spot any reason now either.

Also, IPv6 is doing just fine with using '0' as its first devconf id.

I have no objects to changing this at all but we don't gain much either.
