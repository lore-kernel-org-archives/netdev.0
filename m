From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: add 64bit rate estimators
Date: Wed, 05 Jun 2013 16:07:16 -0700
Message-ID: <1370473636.24311.306.camel@edumazet-glaptop>
References: <1370408447.24311.241.camel@edumazet-glaptop>
	 <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
	 <1370461057.24311.296.camel@edumazet-glaptop>
	 <1370462769.1918.7.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35645 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab3FEXHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 19:07:18 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1303893pab.34
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 16:07:17 -0700 (PDT)
In-Reply-To: <1370462769.1918.7.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 21:06 +0100, Ben Hutchings wrote:

> If you're sure this is the right trade-off then I accept that.  I
> thought you were using packed to ensure the structure layout was
> consistent between userland and kernel, and might not have realised the
> unfortunate effect on alignment.

I'll spin a v2 with clear distinction between kernel/user

And I will also dump the TCA_STATS_RATE_EST64 part only if needed (if
the bps rate is above the 32bit limit)
