From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 08 Oct 2015 09:50:11 -0700
Message-ID: <1444323011.27760.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <1444318627-27883-2-git-send-email-edumazet@google.com>
	 <CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
	 <1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36128 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933270AbbJHQuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 12:50:13 -0400
Received: by pablk4 with SMTP id lk4so59604667pab.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 09:50:12 -0700 (PDT)
In-Reply-To: <1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 09:29 -0700, Eric Dumazet wrote:

> For optimal behavior against DDOS, you need one TCP _listener_ per RX
> queue on the NIC.

I will reword the changelog to make this clear, and fix the htmldocs
warning reported by kbuild in V2.
