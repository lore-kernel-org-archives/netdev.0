From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 08 Jul 2016 17:51:33 +0200
Message-ID: <1467993093.30694.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577FAFFD.2020306@gmx.de>
	 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
	 <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
	 <bd45b0ae-341f-09ed-18f9-fdebfcad733f@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34588 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbcGHPvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:51:37 -0400
Received: by mail-yw0-f195.google.com with SMTP id l125so9028391ywb.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 08:51:37 -0700 (PDT)
In-Reply-To: <bd45b0ae-341f-09ed-18f9-fdebfcad733f@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 11:43 -0400, Hannes Frederic Sowa wrote:

> Exactly, I can very well imagine that the stack becomes unresponsive
> during DDoS, but after the DDoS I don't see a reason why services should
> come up like in IPv4.

If the service uses different listeners, one for IPV4, one (or more) for
IPv6, it is possible that an IPV6 flood leaves the IPV6 part in a sad
state (this can also be an application bug, dealing with some backlog,
like DNS requests)
