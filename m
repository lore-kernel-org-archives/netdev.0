From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: next-20160929 build: 2 failures 4 warnings (next-20160929)
Date: Fri, 30 Sep 2016 00:44:05 +0200
Message-ID: <201609300044.05324.arnd@arndb.de>
References: <E1bpZhb-0002Oz-OQ@optimist> <20160929184737.ragquwy2tmhxo5bn@sirena.org.uk> <57ED66CA.3090903@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Vishwanath Pai <vpai@akamai.com>, Mark Brown <broonie@kernel.org>,
        linaro-kernel@lists.linaro.org, netdev@vger.kernel.org,
        linux-next@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Joshua Hunt <johunt@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: kernel-build-reports@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:49206 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934691AbcI2Wox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 18:44:53 -0400
In-Reply-To: <57ED66CA.3090903@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 September 2016, Vishwanath Pai wrote:
> I have sent a patch for this a couple of days ago to netdev, it hasn't
> made it to net-next yet. Here's the latest one:
> 
> [PATCH net-next v3] netfilter: xt_hashlimit: Fix link error in 32bit
> arch because of 64bit division
> 
> This should fix the link error.

I also did a patch (not submitted yet), but my solution used 32-bit
math for the version 1 case. I think that would be better so we
don't slow down 32-bit architectures too much (div_u64_u64
is very slow).

	Arnd
