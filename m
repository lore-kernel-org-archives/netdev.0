From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Tue, 17 Jan 2017 20:27:57 +0200
Message-ID: <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
References: <1484674356-22363-1-git-send-email-roman@advem.lv> <20170117.125844.253301507252169868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:36022 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdAQSfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:35:50 -0500
Received: by mail-vk0-f51.google.com with SMTP id t8so98171664vke.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:35:50 -0800 (PST)
In-Reply-To: <20170117.125844.253301507252169868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2017 at 19:58, David Miller <davem@davemloft.net> wrote:
> From: Roman Yeryomin <leroi.lists@gmail.com>
> Date: Tue, 17 Jan 2017 19:32:36 +0200
>
>> Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
>> This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)
>
> Those numbers don't mean much without full context.
>
> What kind of system, what kind of traffic, and over what kind of link?

MIPS rb532 board, TCP iperf3 test over 100M link, NATed speed ~55Mbps.
I can do more tests and provide more precise numbers, if needed.

Regards,
Roman
