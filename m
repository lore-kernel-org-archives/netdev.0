From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ip{,6}tunnel: have a shared stats parser/printer
Date: Fri, 18 Dec 2015 11:52:25 +0100
Message-ID: <20151218105225.GA19288@orbyte.nwl.cc>
References: <1449836624-1998-1-git-send-email-phil@nwl.cc>
 <20151217171421.578767cc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42073 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbbLRKw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 05:52:27 -0500
Content-Disposition: inline
In-Reply-To: <20151217171421.578767cc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 05:14:21PM -0800, Stephen Hemminger wrote:
> I just fixed the sscanf formats and after that this patch caused buil=
d error.
> tunnel.c: In function =E2=80=98tnl_print_stats=E2=80=99:
> tunnel.c:211:13: error: =E2=80=98ptr=E2=80=99 undeclared (first use i=
n this function)
>   if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
>              ^
> tunnel.c:211:13: note: each undeclared identifier is reported only on=
ce for each function it appears in
> <builtin>: recipe for target 'tunnel.o' failed

Ah, sorry. I obviously messed up conflict resolution while rebasing thi=
s
onto your master. Fixed version follows.

Thanks, Phil
