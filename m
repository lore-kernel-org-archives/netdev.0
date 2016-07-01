From: John Crispin <john@phrozen.org>
Subject: Re: next-20160701 build: 2 failures 5 warnings (next-20160701)
Date: Fri, 1 Jul 2016 19:46:56 +0200
Message-ID: <ba71c80f-e01e-8ae0-f99d-6ea32c7c1341@phrozen.org>
References: <E1bIuIz-00085X-RP@optimist> <20160701171557.GB6247@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Mark Brown <broonie@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:39431 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbcGARrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 13:47:14 -0400
In-Reply-To: <20160701171557.GB6247@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/07/2016 19:15, Mark Brown wrote:
> On Fri, Jul 01, 2016 at 10:00:09AM +0100, Build bot for Mark Brown wrote:
> 
> Today's -next fails to build am ARM allmodconfig due to:
> 
>> 	arm-allmodconfig
>> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1300:2: error: implicit declaration of function 'mtk_handle_irq' [-Werror=implicit-function-declaration]
>> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1300:25: error: subscripted value is neither array nor pointer nor vector
> 
> due to the recent changes to the interrupt handling code, the function
> has been split into rx and tx functions but the NET_POLL_CONTROLLER code
> hasn't been updated.
> 

Hi Mark,

i'll look into this first thing in the morning.

	John
