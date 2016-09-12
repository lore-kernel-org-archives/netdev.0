From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 12 Sep 2016 23:29:29 +0200
Message-ID: <CAFBinCAHng9JVDeK8SKE0XP79e8pKfHqoq1+0uajPZ_0+k29UA@mail.gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <216F2694-1C1D-44DA-AC15-57ED15C24BBE@bluematt.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Matt Corallo <linux@bluematt.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37135 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbcILV3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 17:29:51 -0400
Received: by mail-wm0-f52.google.com with SMTP id c131so80084363wmh.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 14:29:51 -0700 (PDT)
In-Reply-To: <216F2694-1C1D-44DA-AC15-57ED15C24BBE@bluematt.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

On Sun, Sep 11, 2016 at 10:57 PM, Matt Corallo <linux@bluematt.me> wrote:
> The general advice is to force it into 100M mode then it seems to work fi=
ne.
> There is some issue with the driver seemingly not fully supporting 1G (at
> least on Odroid C2) which needs to be worked out.
thanks for the hint - by "forcing 100M mode" you mean "ethtool =E2=80=93s e=
th0
speed 100 duplex full"?
Do you know more about this issue (or do you just know the
workaround)? It'd be interesting to know which "driver" does not
support Gbit speeds (as there are three drivers involved: realtek PHY
driver, stmmac and Meson stmmac glue driver


Regards,
Martin
