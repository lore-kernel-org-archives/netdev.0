From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v2 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Tue, 27 Sep 2016 00:34:17 +0900
Message-ID: <CAKD1Yr2MHqFMmJyf89pWzopcr07ziVcHqUB+oNWdphKx95nGDg@mail.gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
 <1474797596-13320-1-git-send-email-zenczykowski@gmail.com> <1474797596-13320-3-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:33957 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcIZPej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 11:34:39 -0400
Received: by mail-it0-f49.google.com with SMTP id 15so14242735ita.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 08:34:39 -0700 (PDT)
In-Reply-To: <1474797596-13320-3-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 25, 2016 at 6:59 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> +                 ifp->idev->cnf.rtr_solicits !=3D 0 &&

Given that some of this patch checks for =3D=3D -1, and some of it checks
for !=3D 0... is it possible that setting the value to something
unexpected like -3 will cause any issues to the stack? (Other than
just rendering IPv6 unusable on this interface, which seems like a
given.)
