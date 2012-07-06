From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Fri, 06 Jul 2012 13:58:39 +0200
Message-ID: <1341575919.3265.499.camel@edumazet-glaptop>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62644 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab2GFL6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 07:58:45 -0400
Received: by eeit10 with SMTP id t10so3591584eei.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 04:58:44 -0700 (PDT)
In-Reply-To: <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 13:33 +0200, Christian Riesch wrote:
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> ---

> -		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
> +		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
> +			   ret);


Thats ridiculous

Not all checkpatch warnings are meaningful.

I mean, they probably are for new code, but for existing one this is a
waste of time.
