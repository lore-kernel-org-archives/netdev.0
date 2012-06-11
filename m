From: Thomas Graf <tgraf@infradead.org>
Subject: Re: IPv6 tc filters
Date: Mon, 11 Jun 2012 06:39:54 -0400
Message-ID: <20120611103954.GC28598@canuck.infradead.org>
References: <CAOLNa-fyvic2xzrUwz2WsEap_CgGmU6OwAf=jMPCUVyXbrimVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dragos Ilie <dragos.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:42708 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab2FKKjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 06:39:55 -0400
Content-Disposition: inline
In-Reply-To: <CAOLNa-fyvic2xzrUwz2WsEap_CgGmU6OwAf=jMPCUVyXbrimVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 11, 2012 at 12:31:27PM +0200, Dragos Ilie wrote:
> Do IPv6 tc filters work? According to Linux Advanced Routing & Traffic
> Control HOWTO, IPv6 does not hook into the Routing Policy Database
> (RPDB), thus causing the filters to fail. I would appreciate it if
> someone on this list can confirm or refute this claim. If filters have
> been fixed, since which kernel/iproute2 version do they work?

They do work, tc rules apply to any kind of traffic.

Some specific selectors only work with IPv4 so you need to craft
IPv6 variations yourself.
