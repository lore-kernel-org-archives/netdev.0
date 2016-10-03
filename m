From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Mon, 3 Oct 2016 13:05:14 -0700
Message-ID: <CAM_iQpXPaasqZujSB36XDCW643H3NHcUMcUn59mU2LZiOcbYPA@mail.gmail.com>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
 <CAM_iQpUaXf6crCbbe3+MKsuchJGBE5hnQEDibgFe-MtBoe2v7A@mail.gmail.com> <CANP3RGe2-hpmnQJnGP6JSwNM1YgL-6mKPF8z-GcFaFu7yQtapQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37812 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbcJCUFf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 16:05:35 -0400
Received: by mail-it0-f44.google.com with SMTP id j69so129989975itb.0
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 13:05:35 -0700 (PDT)
In-Reply-To: <CANP3RGe2-hpmnQJnGP6JSwNM1YgL-6mKPF8z-GcFaFu7yQtapQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 3, 2016 at 1:01 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> It is if you don't want build warnings about discarding 'const' qualifier=
.

Why do you need to mark it as const? We don't do this in sysctl_net_ipv4.c.
