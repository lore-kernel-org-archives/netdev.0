From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 19/22] net/smsc911x: Repair broken failure paths
Date: Wed, 30 May 2012 15:16:39 +0800
Message-ID: <CACRpkdY=2j4gRGO4P4RfQDKo+sgV4akAQ6dpP4RbL+XywNCC5A@mail.gmail.com>
References: <1338353260-10097-1-git-send-email-lee.jones@linaro.org>
	<1338353260-10097-20-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	linus.walleij@stericsson.com, grant.likely@secretlab.ca,
	cjb@laptop.org, broonie@opensource.wolfsonmicro.com,
	sameo@linux.intel.com, netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:50490 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756883Ab2E3HQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:16:40 -0400
Received: by qabj40 with SMTP id j40so2894602qab.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:16:40 -0700 (PDT)
In-Reply-To: <1338353260-10097-20-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 30, 2012 at 12:47 PM, Lee Jones <lee.jones@linaro.org> wrote:

> Current failure paths attempt to free resources which we failed to request
> and disable resources which we failed to enable ones. This leads to kernel
> oops/panic. This patch does some simple re-ordering to prevent this from
> happening.
>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Lee Jones <lee.jones@linaro.org>

Acked-by: Linus Walleij <linus.walleij@linaro.org>

Thanks,
Linus Walleij
