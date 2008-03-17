From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 20:04:33 +0200
Message-ID: <200803172004.33246.opurdila@ixiacom.com>
References: <200803171818.17494.opurdila@ixiacom.com> <47DEADC1.1040908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1131 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752420AbYCQSEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 14:04:36 -0400
In-Reply-To: <47DEADC1.1040908@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 March 2008, Rick Jones wrote:
> Octavian Purdila wrote:
> > Hi,
> >
> > Is there a way to prevent getting bind(in6addr_any) failures when we
> > have lots of TIMEWAIT sockets hanging around? It looks like timewait
> > reuse/recyle is not supported in the IPv6 stack.
>
> What is the definition/value of "lots" here?
>

At least 26000, maybe even more. I suspect that when I get the bind failures 
most of the ports in the ip_local_port_range pool are in TIMEWATstate. 

This happens because of the particular traffic I am using, which generates a 
few 1000s of connections per second. The connection lifetime is very short.

While running the same traffic with IPv4, the timewait recyle/reuse features 
kicks in and keeps the number of TIMEWAIT sockets to under a 1000.

Thanks,
tavi




