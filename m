From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RFC EOIP Tunnel
Date: Tue, 21 May 2013 01:08:52 +0200
Message-ID: <20130520230852.GB12098@order.stressinduktion.org>
References: <CAD53P8CY9SFvsrhiZqpxT=P5PtjbqL4LG1tf3O8jpU0yrychUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Boian Bonev <bbonev@ipacct.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51423 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758396Ab3ETXIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 19:08:53 -0400
Content-Disposition: inline
In-Reply-To: <CAD53P8CY9SFvsrhiZqpxT=P5PtjbqL4LG1tf3O8jpU0yrychUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 19, 2013 at 06:31:40PM +0300, Boian Bonev wrote:
> EOIP is a proprietary ethernet over IP tunneling protocol introduced
> by MikroTik's commercial product RouterOS. It uses GRE as protocol id
> but with non-standard header.

Actually, I does get used in BSD land. I have seen several setups some time
ago where gif interfaces got added to a bridge interface, which behaves like
EtherIP then. Prior to FreeBSD 8 they reversed the bytes of the version field
so they still have to provide knobs for backwards compatibility.

> Before going in technical details and submitting patches I want to
> know opinions if this work is suitable for merging upstream or is
> better to be kept as a side kernel patch project.

If the side kernel patch has matured and you are fine with it just propose it
to get merged.

> ps. https://github.com/bbonev/eoip contains 3.2.x patches + somehow
> working but quite crappy config tool

Configuration should be done by iproute.

Greetings,

  Hannes
