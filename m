From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Mon, 11 Nov 2013 14:39:43 -1000
Message-ID: <CAHo-Ooz8aqwOH6HBbBK3AD2=odCQtDyuV8+GdA4SqOWEwX6WTA@mail.gmail.com>
References: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:37072 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab3KLAjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 19:39:44 -0500
Received: by mail-vb0-f50.google.com with SMTP id x11so998867vbb.9
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 16:39:44 -0800 (PST)
In-Reply-To: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack.

I'm sure this breaks whatever the original commit was trying to 'fix',
however it does so in a clearly incorrect manner by effectively
disabling dst mac address filtering.
