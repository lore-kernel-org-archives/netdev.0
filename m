From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: secure_seq: Move net_secret_init() definition into
 CONFIG_IPV6 if block
Date: Sun, 6 Oct 2013 13:29:47 -0300
Message-ID: <CAOMZO5B+wr67_xw867w8GiuYT_wxBo-jOw-49dogPzZRNdpWew@mail.gmail.com>
References: <1381003790-12731-1-git-send-email-festevam@gmail.com>
	<20131005.162752.155685316245760253.davem@davemloft.net>
	<CAOesGMi6LuP7uVJnHOgpG2RK2Q0R3bJ4kG1ZY3=b-W3k0YhnBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, edumazet <edumazet@google.com>,
	hannes@strressinduktion.org,
	Network Development <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44999 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab3JFQ3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 12:29:48 -0400
Received: by mail-wi0-f174.google.com with SMTP id hj3so3724769wib.7
        for <netdev@vger.kernel.org>; Sun, 06 Oct 2013 09:29:47 -0700 (PDT)
In-Reply-To: <CAOesGMi6LuP7uVJnHOgpG2RK2Q0R3bJ4kG1ZY3=b-W3k0YhnBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Olof,

On Sun, Oct 6, 2013 at 2:25 AM, Olof Johansson <olof@lixom.net> wrote:

> You get it if you have CONFIG_NET enabled, but CONFIG_INET off. We
> seem to have a few defconfigs on arm that has that setting, likely
> because they lack native network interfaces but need local unix
> sockets. Or whatever. But that's how you hit it.
>
> Steps to reproduce, even with ARCH=sparc:
>
> make allnoconfig
> edit .config, set CONFIG_NET=y
> yes "" | make oldconfig
> make

Yes, I fixed the commit log and patch in v2.

Regards,

Fabio Estevam
