From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net 1/1] net: fec: fix multicast filtering hardware setup
Date: Fri, 10 Feb 2017 19:19:36 -0200
Message-ID: <CAOMZO5A=JQHDU6qFqzzkKQWStUqhDngRcbuf-qmSWgZUd7VRyA@mail.gmail.com>
References: <1486706069-29124-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34289 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdBJVTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 16:19:37 -0500
Received: by mail-oi0-f67.google.com with SMTP id w144so3371019oiw.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:19:37 -0800 (PST)
In-Reply-To: <1486706069-29124-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 3:54 AM, Andy Duan <fugang.duan@nxp.com> wrote:
> Fix hardware setup of multicast address hash:
> - Never clear the hardware hash (to avoid packet loss)
> - Construct the hash register values in software and then write once
> to hardware
>
> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
> Signed-off-by: Rui Sousa <rui.sousa@nxp.com>

It seems you missed to put Rui's name in the From: field.
