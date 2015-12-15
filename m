From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH v5 4/4] net: diag: Support destroying TCP socketsr
Date: Tue, 15 Dec 2015 19:36:37 +0100
Message-ID: <CAHo-OoxJHuuYqzpSmYkMKvXjmesMD=_G5_G5uBndNSPHTy8qBw@mail.gmail.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
	<1450199868-93712-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Kline <ek@google.com>, Tom Herbert <tom@herbertland.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33530 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620AbbLOSgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:36:39 -0500
Received: by mail-lf0-f47.google.com with SMTP id p203so13343296lfa.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 10:36:38 -0800 (PST)
In-Reply-To: <1450199868-93712-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd tend to agree that reset or abort would be preferable to destroy.
After all... the socket doesn't actually go away.
