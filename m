From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Sat, 07 Jul 2012 10:36:49 +0200
Message-ID: <1341650209.3265.1320.camel@edumazet-glaptop>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
	 <1341575919.3265.499.camel@edumazet-glaptop>
	 <CANEJEGvEUYNpWd6FPFnONk4AUFqLsD-oXG7ZRqibqhqxfUYKZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41075 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab2GGIgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 04:36:54 -0400
Received: by wgbdr13 with SMTP id dr13so9952336wgb.1
        for <netdev@vger.kernel.org>; Sat, 07 Jul 2012 01:36:53 -0700 (PDT)
In-Reply-To: <CANEJEGvEUYNpWd6FPFnONk4AUFqLsD-oXG7ZRqibqhqxfUYKZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 14:43 -0700, Grant Grundler wrote:

> Christian is clearly running checkpatch.pl as suggested in
> Documentation/SubmittingPatches. He missed the part about "You should
> be able to justify all violations that remain in your patch." and/or
> didn't know about "fixing existing code is a waste of time".
> 
> Given the extent of the changes Christian is making (factoring out
> asix common code from model specific code), it's helpful to have clean
> checkpatch runs. I don't believe it's a waste of time to apply this
> patch. Is it conflicting with any other code changes that are in
> flight now?

It was a waste of time for me, at least (Since I was CCed for the
patch), and just sent my personal opinion on checkpatch generated
patches.

Splitting a perfectly good line :

netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);

into

netdev_err(dev->net, "Error reading PHYID register: %02x\n",
	   ret);

is a clear sign of how stupid checkpatch is.

And fact we can spend time on discussions about checkpatch is
astonishing.

Automatic tools should be smart and ease people tasks, not
slowing them.

Note that Christian patch serie in itself is good, I don't want to block
it at all.
