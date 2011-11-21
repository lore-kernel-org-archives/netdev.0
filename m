From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems with dropped packets on bonded interface for 3.x
 kernels
Date: Mon, 21 Nov 2011 09:02:29 +0100
Message-ID: <1321862549.17419.12.camel@edumazet-laptop>
References: <20111121051603.GB3702@china>
	 <1321857123.17419.2.camel@edumazet-laptop> <20111121074453.GA7596@china>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43966 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304Ab1KUICd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 03:02:33 -0500
Received: by mail-bw0-f46.google.com with SMTP id 11so6213047bke.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 00:02:32 -0800 (PST)
In-Reply-To: <20111121074453.GA7596@china>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 novembre 2011 =C3=A0 01:44 -0600, Albert Chin a =C3=A9crit =
:

> So only "unknown" protocols are dropped? I just ran tcpdump for 96
> packets and inspected the output. The only packets received are LACP,
> ARP, STP (Spanning Tree Protocol), DTP (Dynamic Trunking Protocol).
> How are these "unknown"?

No protocol handler is setup to analyze some them in your box.

(ARP is handled of course)

Like if you receive IPv6 packets while IPv6 was not compiled/loaded int=
o
your kernel.

Nothing you have to worry about. We receive plenty of unknown packets
these days...
