From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] secure_seq: initialize secret at boot instead of at runtime
Date: Sun, 15 Jan 2017 16:43:21 +0100
Message-ID: <CAHmME9ryEXPFKz6BsHWr4aNyGgxuftyRm452rzjGp9iPXLtKRw@mail.gmail.com>
References: <20170115140136.23135-1-Jason@zx2c4.com> <587B973B.8040008@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:39727 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751098AbdAOPnf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 10:43:35 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 14f88756
        for <netdev@vger.kernel.org>;
        Sun, 15 Jan 2017 15:33:00 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 093abb9d (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Sun, 15 Jan 2017 15:33:00 +0000 (UTC)
Received: by mail-ot0-f176.google.com with SMTP id 104so31315763otd.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 07:43:23 -0800 (PST)
In-Reply-To: <587B973B.8040008@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 4:37 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> commit aebda156a570782a86fc4426842152237a19427d
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Apr 29 05:58:52 2013 +0000
>
>     net: defer net_secret[] initialization

Thanks for that. Suspected as much. Should have checked the log first
myself. Makes sense.
