From: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: fix spurious timestamping callbacks
Date: Sun, 24 Apr 2016 11:24:12 +0300
Message-ID: <CAKHjkjnGBoMw1-HJZCyUHahFv=a+Fb6XzonSARgk3kp-nBk4Zw@mail.gmail.com>
References: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34823 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbcDXIYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 04:24:14 -0400
Received: by mail-wm0-f68.google.com with SMTP id e201so14389642wme.2
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 01:24:13 -0700 (PDT)
In-Reply-To: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When multiple skb are TX-completed in a row, we might incorrectly keep
> a timestamp of a prior skb and cause extra work.
>
> Fixes: ec693d47010e8 ("net/mlx4_en: Add HW timestamping (TS) support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Willem de Bruijn <willemb@google.com>

Other than the commit message issue raised by Or,

Reviewed-by: Eran Ben Elisha <eranbe@mellanox.com>
