From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Fri, 6 Jul 2012 14:43:19 -0700
Message-ID: <CANEJEGvEUYNpWd6FPFnONk4AUFqLsD-oXG7ZRqibqhqxfUYKZA@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
	<1341575919.3265.499.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34729 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005Ab2GFVnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 17:43:20 -0400
Received: by obbuo13 with SMTP id uo13so15731258obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 14:43:19 -0700 (PDT)
In-Reply-To: <1341575919.3265.499.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 6, 2012 at 4:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-07-06 at 13:33 +0200, Christian Riesch wrote:
>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>> ---
>
>> -             netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
>> +             netdev_err(dev->net, "Error reading PHYID register: %02x\n",
>> +                        ret);
>
>
> Thats ridiculous

Agreed. But it's not Christian's fault and I'm pretty sure you aren't
blaming him.

> Not all checkpatch warnings are meaningful.

Agreed.

> I mean, they probably are for new code, but for existing one this is a
> waste of time.

Christian is clearly running checkpatch.pl as suggested in
Documentation/SubmittingPatches. He missed the part about "You should
be able to justify all violations that remain in your patch." and/or
didn't know about "fixing existing code is a waste of time".

Given the extent of the changes Christian is making (factoring out
asix common code from model specific code), it's helpful to have clean
checkpatch runs. I don't believe it's a waste of time to apply this
patch. Is it conflicting with any other code changes that are in
flight now?

thanks,
grant
