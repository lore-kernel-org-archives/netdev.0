From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Mon, 11 Nov 2013 17:12:10 -0800
Message-ID: <CAMEtUuzmZd0RXO+=YhCW7OwfE1kvc2aA2K0gqXRN+LwS-O1f2w@mail.gmail.com>
References: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
	<CAHo-Ooz8aqwOH6HBbBK3AD2=odCQtDyuV8+GdA4SqOWEwX6WTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <zenczykowski@gmail.com>,
	isaku.yamahata@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49257 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab3KLBML convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 20:12:11 -0500
Received: by mail-we0-f174.google.com with SMTP id p61so5381717wes.33
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 17:12:10 -0800 (PST)
In-Reply-To: <CAHo-Ooz8aqwOH6HBbBK3AD2=odCQtDyuV8+GdA4SqOWEwX6WTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 4:39 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> Ack.
>
> I'm sure this breaks whatever the original commit was trying to 'fix'=
,
> however it does so in a clearly incorrect manner by effectively
> disabling dst mac address filtering.

actually it doesn't break it. Isaku's testcase works for me.
