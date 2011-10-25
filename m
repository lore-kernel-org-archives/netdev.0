From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow CAP_NET_RAW to setsockopt SO_PRIORITY
Date: Tue, 25 Oct 2011 02:25:46 -0400 (EDT)
Message-ID: <20111025.022546.1784159727449615100.davem@davemloft.net>
References: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
	<20111025.005819.456617923859129015.davem@davemloft.net>
	<CANP3RGfdimCqGL=kdVQdYY0KHqVuVL3CL6arRh3EhdNhyrv9cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab1JYGZv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 02:25:51 -0400
In-Reply-To: <CANP3RGfdimCqGL=kdVQdYY0KHqVuVL3CL6arRh3EhdNhyrv9cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 24 Oct 2011 22:07:20 -0700

> A raw socket can already spew traffic, ie. packets, with any content.
> This includes VLAN tags and IPv4 TOS field, and IPv6 TCLASS field.
> These are the fields used for packet prioritization at switches and i=
n
> the rest of network fabric.

SO_PRIORITY can control prioritizations that are not influenced
by packet contents.

There is a huge difference.
