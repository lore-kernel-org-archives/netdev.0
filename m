From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] gianfar: convert u64 status counters to
 atomic64_t
Date: Wed, 13 Feb 2013 08:14:25 -0800
Message-ID: <1360772065.6884.23.camel@edumazet-glaptop>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
	 <1360715064-2689-3-git-send-email-paul.gortmaker@windriver.com>
	 <511BAFC4.9060006@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34889 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934312Ab3BMQO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 11:14:29 -0500
Received: by mail-pa0-f44.google.com with SMTP id kp1so789374pab.31
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 08:14:28 -0800 (PST)
In-Reply-To: <511BAFC4.9060006@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 17:22 +0200, Claudiu Manoil wrote:

> At least it seems that this conversion results in fewer asm
> instructions, as apparently addze and the double lwz/stw are
> not generated anymore. Hopefully it's faster too :P

Strange, could you show us these asm instructions ?
