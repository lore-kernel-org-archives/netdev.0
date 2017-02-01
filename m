From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Thu, 2 Feb 2017 01:48:10 +0200
Message-ID: <CAJ3xEMh6eiV_c5_s8i0HtFPFQAmU5He6iUdS7JP7h4VL1_+GqA@mail.gmail.com>
References: <20170131205843.23235-1-saeedm@mellanox.com> <20170131205843.23235-2-saeedm@mellanox.com>
 <20170201.122232.468887635709421897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f169.google.com ([74.125.82.169]:35446 "EHLO
        mail-ot0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdBAXsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 18:48:11 -0500
Received: by mail-ot0-f169.google.com with SMTP id 65so302970918otq.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 15:48:10 -0800 (PST)
In-Reply-To: <20170201.122232.468887635709421897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 7:22 PM, David Miller <davem@davemloft.net> wrote:

[..]

> You're propagating values into a u32 field, which you are explicitly
> performing 32-bit endianness conversions upon.

> Just use "u32" for a local variable and get rid of all of these casts.

ok, will do that
