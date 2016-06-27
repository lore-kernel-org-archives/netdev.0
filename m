From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH RFC 3/3] ARM64: dts: meson-gxbb: use the new meson8b DWMAC glue
Date: Mon, 27 Jun 2016 12:44:13 +0200
Message-ID: <CAFBinCB6i2-ZUDupAXUZkQO9y93rtCvguD_avdY=Ze72wxQKpw@mail.gmail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
 <20160625165013.15917-4-martin.blumenstingl@googlemail.com> <20160627092448.GA3275@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-amlogic@lists.infradead.org, mark.rutland@arm.com,
	khilman@baylibre.com, robh+dt@kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: Carlo Caione <carlo@caione.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38177 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbcF0Koe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 06:44:34 -0400
Received: by mail-wm0-f44.google.com with SMTP id r201so108940093wme.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 03:44:33 -0700 (PDT)
In-Reply-To: <20160627092448.GA3275@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 11:24 AM, Carlo Caione <carlo@caione.org> wrote:
> A syscon is a region containing a set of miscellaneous registers used
> for several reasons by several devices [1]. It this case there is really
> no need to define a new syscon node since those two registers are only
> used by your driver.
I can easily change it back if that's the way to go.
Before I do that: could you please confirm that "mp2_clk_out" (which
is controlled by PRG_ETH0/offset 0x0 bits 7-9) is not something which
has to be available through the common clk framework?
