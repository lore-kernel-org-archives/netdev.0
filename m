From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v2 01/13] net: ethernet: aquantia: Make and configuration files.
Date: Thu, 12 Jan 2017 00:05:04 +0200
Message-ID: <CAKoUAr=oxiQnQZnHYo2=yyUx=xftaMy3o5amMaRbf+xvQGpLwQ@mail.gmail.com>
References: <cover.1483999588.git.vomlehn@texas.net> <0b0d8974bdbfa66ab3bc4460f32f7916dd54b85a.1483999588.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David VomLehn <vomlehn@texas.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35827 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdAKWFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 17:05:05 -0500
Received: by mail-it0-f67.google.com with SMTP id 203so569770ith.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 14:05:05 -0800 (PST)
In-Reply-To: <0b0d8974bdbfa66ab3bc4460f32f7916dd54b85a.1483999588.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


> +++ b/drivers/net/ethernet/aquantia/Makefile
> @@ -0,0 +1,44 @@
...
...
> > +obj-$(CONFIG_AQTION) += atlantic.o
> +
> +atlantic-objs := aq_main.o \
> +       aq_nic.o \
> +       aq_pci_func.o \

Why twice aq_nic.o ? it appears two lines earlier:

> +       aq_nic.o \
> +       aq_vec.o \
> +       aq_ring.o \
...
...

Regards,
Rami Rosen
