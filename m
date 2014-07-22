From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Tue, 22 Jul 2014 11:51:06 +0200
Message-ID: <1406022666.10255.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	 <1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140722.010105.2036198226851589509.davem@davemloft.net>
	 <CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:43313 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbaGVJv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 05:51:26 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so5600514wib.9
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 02:51:22 -0700 (PDT)
In-Reply-To: <CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-22 at 16:53 +0800, Sonic Zhang wrote:

> if (!--A)
> 
> doesn't equal to
> 
> if (A--)
>         if (!A)

It really does, no matter what you think.

In all cases, A is decremented.

In all cases, final action is done if and only if A was 1 before the
test(s)

Thats simple logic, and all your arguments about NAPI, IRQ, and moon
phase are irrelevant.
