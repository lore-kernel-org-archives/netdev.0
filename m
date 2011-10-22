From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY
 setsockopt
Date: Sat, 22 Oct 2011 04:40:24 -0400 (EDT)
Message-ID: <20111022.044024.1119624563295810913.davem@davemloft.net>
References: <CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com>
	<20111022.025836.1306779710775525629.davem@davemloft.net>
	<CAHo-OoyVSbsxb8U3Y5WCNRsxjr00g1O3HJcT1fmu5cmP5i-JsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024Ab1JVIk2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 04:40:28 -0400
In-Reply-To: <CAHo-OoyVSbsxb8U3Y5WCNRsxjr00g1O3HJcT1fmu5cmP5i-JsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Sat, 22 Oct 2011 01:27:03 -0700

> I am attempting to allow not-fully-code-audited nor fully trusted app=
s to run
> in a cgroup containerized environment, with many apps in many
> containers (not 1:1, has hierarchies) on a single kernel.

Extend, if necessary, the cgroup classifier so you can use it to clip
off the socket inherited priority in the SKB for this cgroup.

Really, this control has no business in the socket API layer.
