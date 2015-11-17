From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to do TCP tx checksums
Date: Mon, 16 Nov 2015 21:47:59 -0800
Message-ID: <1447739279.22599.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <564A72D3.1050407@candelatech.com>
	 <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35623 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbKQFsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 00:48:04 -0500
Received: by pacej9 with SMTP id ej9so93232762pac.2
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 21:48:01 -0800 (PST)
In-Reply-To: <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-16 at 21:02 -0800, Tom Herbert wrote:

> It's really hard to tell what is happening without seeing the full
> patch your using. Maybe you're not setting the TCP correctly or
> transport header is not set right in skb.

BTW, using trafgen from netsniff-ng would save you Ben lots of
headaches.

No need for kernel patches...
