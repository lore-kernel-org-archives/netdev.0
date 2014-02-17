From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Mon, 17 Feb 2014 14:02:02 +0400
Message-ID: <CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com>
References: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
	<20140213001624.GJ11150@order.stressinduktion.org>
	<20140217.001545.981758741332832466.davem@davemloft.net>
	<20140217093231.GA4609@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	fx.lebail@yahoo.com, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38343 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbaBQKHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:07:51 -0500
Received: by mail-ig0-f171.google.com with SMTP id uy17so4858179igb.4
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 02:07:51 -0800 (PST)
In-Reply-To: <20140217093231.GA4609@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Mon, Feb 17, 2014 at 1:32 PM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> I don't have strong opinions for or against this patch.
>
> I was only involved in the original thread because F-X claimed that
> draft-iab-anycast-arch-implications (now RFC 7094) allows the use of anycast
> addresses for TCP, which is not what RFC 7094 is saying. There is no
> recommendation concerning TCP in the RFC and the situation is rather unclear.

The same is here.

Using anycast as source or bind address, why not?

Use of anycast with TCP? Logically impossible, ergo prohibited.
If someone wants to play with fire, the option can be left hidden behind
a sysctl disabled by default.
