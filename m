From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sat, 1 Oct 2016 22:26:25 +0200
Message-ID: <CAFBinCC0ihYvf9xYkS3cvLFURs5=gynWoLUnNjeVxA0t0u_f1A@mail.gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38855 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbcJAU0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:26:47 -0400
Received: by mail-wm0-f45.google.com with SMTP id p138so83354679wmb.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:26:46 -0700 (PDT)
In-Reply-To: <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 5:30 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> as rule of thumb, I can only suggest you to see the RXDLY and TXDLY
> and if you have (or need!) the resistor on PCB to have the 2ns of
> extra delay. This can impact on RGMII case (1G).
> Indeed, if this is true, I should expect some problem also when ping.
I did a simple ping-test:

device to computer:
50 packets transmitted, 50 received, 0% packet loss, time 50170ms
rtt min/avg/max/mdev = 0.457/0.659/0.779/0.083 ms

computer to device:
50 packets transmitted, 50 received, 0% packet loss, time 49001ms
rtt min/avg/max/mdev = 0.483/0.629/1.356/0.114 ms

both running simultaneously, device to computer:
51 packets transmitted, 50 received, 1% packet loss, time 51182ms
rtt min/avg/max/mdev = 0.459/0.648/0.729/0.082 ms

both running simultaneously, computer to device:
50 packets transmitted, 38 received, 24% packet loss, time 48997ms
rtt min/avg/max/mdev = 0.482/0.594/0.640/0.053 ms
