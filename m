From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/stmmac: Use clk_prepare_enable and
 clk_disable_unprepare
Date: Fri, 21 Sep 2012 15:00:19 -0400 (EDT)
Message-ID: <20120921.150019.2260891366589656756.davem@davemloft.net>
References: <1348225589-8126-1-git-send-email-sr@denx.de>
	<CAKohpomw8u5wgtWAukfqH7t3iwge+jyFxBY4bv6AT2u5c_=arA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sr@denx.de, netdev@vger.kernel.org, peppe.cavallaro@st.com,
	spear-devel@list.st.com
To: viresh.kumar@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933085Ab2IUTAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:00:21 -0400
In-Reply-To: <CAKohpomw8u5wgtWAukfqH7t3iwge+jyFxBY4bv6AT2u5c_=arA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Fri, 21 Sep 2012 16:51:28 +0530

> On 21 September 2012 16:36, Stefan Roese <sr@denx.de> wrote:
>> This patch fixes an issue introduced by commit ID 6a81c26f
>> [net/stmmac: remove conditional compilation of clk code], which
>> switched from the internal stmmac_clk_{en}{dis}able calls to
>> clk_{en}{dis}able. By this, calling clk_prepare and clk_unprepare
>> was removed.
>>
>> clk_{un}prepare is mandatory for platforms using common clock framework.
>> Since these drivers are used by SPEAr platform, which supports common
>> clock framework, add clk_{un}prepare() support for them. Otherwise
>> the clocks are not correctly en-/disabled and ethernet support doesn't
>> work.
> 
> I can't believe i have done this. :)
> 
> IIRC, when i wrote this code prepare/unprepare weren't there. And by the
> time my code got merged, they were. And this mistake was missed there.
> 
> Thanks for fixing it.
> 
> Reviewed-by: Viresh Kumar <viresh.kumar@linaro.org>

Applied, thanks.
