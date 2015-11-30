From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH RFC] libnetlink: introduce DECLARE_NLREQ
Date: Mon, 30 Nov 2015 09:20:51 -0800
Message-ID: <20151130092051.0feb5fe0@xeon-e3>
References: <1448544365-23153-1-git-send-email-phil@nwl.cc>
	<20151129120752.73834f50@xeon-e3>
	<20151130154724.GC17712@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:20120 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754408AbbK3RUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 12:20:46 -0500
In-Reply-To: <20151130154724.GC17712@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Nov 2015 16:47:25 +0100
Phil Sutter <phil@nwl.cc> wrote:

> libmnl looks nice and simple (unlike libnl I was initially looking at by
> accident). Now how to pull this off:
> 
> I don't think mandatorily depending on libmnl will be acceptable, do
> you? So I can imagine two ways to do this:

Having libmnl be mandatory is fine, but please put in net-next.
Every distro has libmnl and as long as it is documented not a big deal.

> A) Have a libmnl version of lib/libnetlink.c which is used instead of
>    the old one if libmnl is present.
> 
> B) Pull a copy of libmnl into iproute2 sources so it's always available
>    (as fallback) and make it replace lib/libnetlink.c. This sounds worse
>    than it is, using git-subtree allows to do this without imposing user
>    knowledge about it (like git-submodule does).

Just incrementally change code to use libmnl instead of libnetlink.
Start with simple stuff.
