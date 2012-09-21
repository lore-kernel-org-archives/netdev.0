From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH] net/stmmac: Use clk_prepare_enable and clk_disable_unprepare
Date: Fri, 21 Sep 2012 16:51:28 +0530
Message-ID: <CAKohpomw8u5wgtWAukfqH7t3iwge+jyFxBY4bv6AT2u5c_=arA@mail.gmail.com>
References: <1348225589-8126-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	spear-devel <spear-devel@list.st.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:63965 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756312Ab2IULV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 07:21:29 -0400
Received: by ieak13 with SMTP id k13so5123046iea.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 04:21:28 -0700 (PDT)
In-Reply-To: <1348225589-8126-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 September 2012 16:36, Stefan Roese <sr@denx.de> wrote:
> This patch fixes an issue introduced by commit ID 6a81c26f
> [net/stmmac: remove conditional compilation of clk code], which
> switched from the internal stmmac_clk_{en}{dis}able calls to
> clk_{en}{dis}able. By this, calling clk_prepare and clk_unprepare
> was removed.
>
> clk_{un}prepare is mandatory for platforms using common clock framework.
> Since these drivers are used by SPEAr platform, which supports common
> clock framework, add clk_{un}prepare() support for them. Otherwise
> the clocks are not correctly en-/disabled and ethernet support doesn't
> work.

I can't believe i have done this. :)

IIRC, when i wrote this code prepare/unprepare weren't there. And by the
time my code got merged, they were. And this mistake was missed there.

Thanks for fixing it.

Reviewed-by: Viresh Kumar <viresh.kumar@linaro.org>
