From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Mon, 9 Jul 2012 11:48:39 +0200
Message-ID: <CABkLObowkQHbOeONpchc=dsbh3zoAUX7=gjw_pp6F8dtGEovZw@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
	<1341575919.3265.499.camel@edumazet-glaptop>
	<CANEJEGvEUYNpWd6FPFnONk4AUFqLsD-oXG7ZRqibqhqxfUYKZA@mail.gmail.com>
	<1341650209.3265.1320.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Grundler <grundler@chromium.org>, netdev@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:45372 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab2GIJsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 05:48:40 -0400
Received: by gglu4 with SMTP id u4so9862144ggl.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 02:48:39 -0700 (PDT)
In-Reply-To: <1341650209.3265.1320.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On Sat, Jul 7, 2012 at 10:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-07-06 at 14:43 -0700, Grant Grundler wrote:
>
>> Christian is clearly running checkpatch.pl as suggested in
>> Documentation/SubmittingPatches. He missed the part about "You should
>> be able to justify all violations that remain in your patch." and/or
>> didn't know about "fixing existing code is a waste of time".
>>
>> Given the extent of the changes Christian is making (factoring out
>> asix common code from model specific code), it's helpful to have clean
>> checkpatch runs. I don't believe it's a waste of time to apply this
>> patch. Is it conflicting with any other code changes that are in
>> flight now?
>
> It was a waste of time for me, at least (Since I was CCed for the
> patch), and just sent my personal opinion on checkpatch generated
> patches.
>
> Splitting a perfectly good line :
>
> netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
>
> into
>
> netdev_err(dev->net, "Error reading PHYID register: %02x\n",
>            ret);
>
> is a clear sign of how stupid checkpatch is.
>
> And fact we can spend time on discussions about checkpatch is
> astonishing.
>
> Automatic tools should be smart and ease people tasks, not
> slowing them.

Thanks for your comments! I admit that I was just annoyed by the lots
of checkpatch warnings and therefore just brainlessly did everything
to make it stop complaining, there was not much thinking involved. I
will try to be more sensible when I put together the next version.

But first I'd like to draw your attention to the other patches in the
patchset :-) I asked a few questions in the cover letter [1] and I
would like to hear your opinion about it. Thanks a lot!

>
> Note that Christian patch serie in itself is good, I don't want to block
> it at all.

Thanks :-)

Regards, Christian


[1] http://marc.info/?l=linux-netdev&m=134157544400926&w=2
