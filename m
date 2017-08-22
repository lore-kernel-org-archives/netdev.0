From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] selftests/net: Add a test to validate
 behavior of rx timestamps
Date: Tue, 22 Aug 2017 15:15:27 -0400
Message-ID: <CAF=yD-KP6KaQPm5jmVtD5AE3Yz2HEALPV9P6Z7k9p_fuyVdz_Q@mail.gmail.com>
References: <20170822172703.31703-1-maloneykernel@gmail.com> <20170822172703.31703-3-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36041 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753085AbdHVTQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 15:16:08 -0400
Received: by mail-oi0-f52.google.com with SMTP id g131so195678358oic.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 12:16:08 -0700 (PDT)
In-Reply-To: <20170822172703.31703-3-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static struct socket_type socket_types[] = {
> +       { "ip",         SOCK_DGRAM,     IPPROTO_IP },
> +       { "udp",        SOCK_DGRAM,     IPPROTO_UDP },

I think the intent is to have a SOCK_RAW case.
