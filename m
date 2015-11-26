From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 18:58:32 +0200
Message-ID: <87lh9kn1dz.fsf@kamboji.qca.qualcomm.com>
References: <E1a1sVV-00079q-My@optimist> <20151126121551.GE1929@sirena.org.uk>
	<87y4dllysz.fsf@kamboji.qca.qualcomm.com>
	<20151126132228.GG1929@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linaro-kernel@lists.linaro.org>,
	<kernel-build-reports@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <ath10k@lists.infradead.org>,
	<linux-next@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:61245 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbKZQ6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 11:58:52 -0500
In-Reply-To: <20151126132228.GG1929@sirena.org.uk> (Mark Brown's message of
	"Thu, 26 Nov 2015 13:22:28 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Brown <broonie@kernel.org> writes:

> On Thu, Nov 26, 2015 at 02:39:40PM +0200, Kalle Valo wrote:
>> Mark Brown <broonie@kernel.org> writes:
>
>> > It looks like this was somehow triggered as part of the reorganisation
>> > of the WiFi directory structure.
>
>> This is surprising and also worrying, any ideas why? It would be good to
>> understand the root cause in case there's a bug in wireless drivers
>> directory reorganisation.
>
> No, I didn't make much effort to check though since the use of ifdef was
> clearly a bug waiting to happen anyway, I was more surprised it worked
> at all than anything.

Michal Marek explains[1] that this is due to commit cf4f21938e13
("kbuild: Allow to specify composite modules with modname-m") and has
nothing to do with the wireless drivers reorganisation. I'll drop this
patch as Michal will apply his fix to the kbuild tree.

[1] https://patchwork.kernel.org/patch/7707801/

-- 
Kalle Valo
