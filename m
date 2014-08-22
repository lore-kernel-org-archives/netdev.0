From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP output handling bug ?
Date: Fri, 22 Aug 2014 11:30:08 -0700
Message-ID: <1408732208.5604.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140821172445.7c1ba422@uryu.home.lan>
	 <20140822021341.GB14353@redhat.com>
	 <1408715790.5604.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140822.104118.710757967194596933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, stephen@networkplumber.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:58406 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbaHVSaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:30:10 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so17281913pad.27
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 11:30:09 -0700 (PDT)
In-Reply-To: <20140822.104118.710757967194596933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-22 at 10:41 -0700, David Miller wrote:

> What about ECE/CWR?

TCP fastopen begins its life with a fresh socket.

We received no packet from the peer yet for this flow that we are
building.
