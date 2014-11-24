From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] fix return code from fib_rules_lookup()
Date: Mon, 24 Nov 2014 10:34:18 -0800
Message-ID: <CAOxq_8N-jVdsJPyjiqUVGLJnbC8L7AoB8vKv5xcsOQiuPoAPDw@mail.gmail.com>
References: <1416637521-20173-1-git-send-email-ani@arista.com> <20141123.142438.1266838467850561800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: maze <maze@google.com>, Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	fruggeri <fruggeri@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:57746 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbaKXSej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 13:34:39 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so9385986ieb.12
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 10:34:39 -0800 (PST)
In-Reply-To: <20141123.142438.1266838467850561800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2014 at 11:24 AM, David Miller <davem@davemloft.net> wrote:

>
> How does this relate to the already committed:
>
> commit 49dd18ba4615eaa72f15c9087dea1c2ab4744cf5
> Author: Panu Matilainen <pmatilai@redhat.com>
> Date:   Fri Nov 14 13:14:32 2014 +0200
>
>     ipv4: Fix incorrect error code when adding an unreachable route
>

Oh wow! This was committed only a week or so ago. My tree wasn't
updated. Sorry. Yes, this is the same problem I was referring to and
this patch should fix it.

Ani
