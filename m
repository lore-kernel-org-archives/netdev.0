From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 02 Feb 2014 10:52:34 -0800
Message-ID: <1391367154.28432.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140202.004538.1011276314292086521.davem@davemloft.net>
	 <CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:43329 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbaBBSwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 13:52:37 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so5768642iec.10
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 10:52:36 -0800 (PST)
In-Reply-To: <CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-02 at 10:43 -0500, Neal Cardwell wrote:
> Hi David,
> 
> That was true in 3.12 and earlier, but AFAICT since Eric's 05dbc7b
> ("tcp/dccp: remove twchain") in 3.13-rc1, there is no head->twchain,
> and instead all the connections (both tcp_sock and timewait flavor)
> are on the head->chain, so that we do need to check for timewait
> sockets. :-)


Note that Neal fix needs a different form for stable trees.

Thats maybe David concern ;)
