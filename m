From: Cong Wang <cwang@twopensource.com>
Subject: Re: Setting mac address of loopback device
Date: Thu, 23 Jan 2014 16:55:13 -0800
Message-ID: <CAHA+R7OghbTx1VZj=2P7XROgiLu7vFZ_uV6NybgOtkc3V3P3Yg@mail.gmail.com>
References: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com>
	<20140123234920.GM7269@order.stressinduktion.org>
	<CAHA+R7PtkiQRgJwTJ4Pq2zTWs9N5x22VFEcK4QMv65SG7bX1Tw@mail.gmail.com>
	<20140124001026.GN7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:59270 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaAXAzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:55:15 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so2008268lbd.23
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:55:14 -0800 (PST)
In-Reply-To: <20140124001026.GN7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 4:10 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> It seems accurate. Only other idea is to try netfilter with TEE target on
> loopback.
>

xt_TEE should work for me too. But for applications, using iptables
is at least as hard as using a tc action.

Thanks!
