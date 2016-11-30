From: Kevin Hilman <khilman@baylibre.com>
Subject: Re: [PATCH net 5/7] net: ethernet: stmmac: dwmac-meson8b: fix probe error path
Date: Wed, 30 Nov 2016 08:43:16 -0800
Message-ID: <m2fum8kjff.fsf@baylibre.com>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
        <1480516195-27696-6-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32819 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbcK3QnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:43:18 -0500
Received: by mail-pf0-f181.google.com with SMTP id d2so40021953pfd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:43:18 -0800 (PST)
In-Reply-To: <1480516195-27696-6-git-send-email-johan@kernel.org> (Johan
        Hovold's message of "Wed, 30 Nov 2016 15:29:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johan Hovold <johan@kernel.org> writes:

> Make sure to disable clocks before returning on late probe errors.
>
> Fixes: 566e82516253 ("net: stmmac: add a glue driver for the Amlogic
> Meson 8b / GXBB DWMAC")
> Signed-off-by: Johan Hovold <johan@kernel.org>

Acked-by: Kevin Hilman <khilman@baylibre.com>
