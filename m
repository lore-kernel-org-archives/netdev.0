From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Mon, 29 Sep 2014 14:49:00 -0700
Message-ID: <CA+mtBx8rpELodiiez8LkKupKBr9ynbQhrmAq8tcD4QKXHNjyaw@mail.gmail.com>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
	<CA+mtBx95KFr=3h_TZWBeM6e7EF4sKAmjRpz5vLxGwi8xC+qQuw@mail.gmail.com>
	<20140929211158.GA11633@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:50412 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbaI2VtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:49:00 -0400
Received: by mail-ig0-f178.google.com with SMTP id l13so2736327iga.17
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 14:49:00 -0700 (PDT)
In-Reply-To: <20140929211158.GA11633@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 2:11 PM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <therbert@google.com> wrote:
>> Thanks for doing this! Can you add a little description in commit log
>> on test results, something that would indicate accounting is correct.
>
> Do you have any specific test in mind?
>
> I ran 'super_netperf 40' for 20 minutes without stalls/hangups and
> bql monitor seemed to look ok.
>
> Anything else I should use/test with?
>
Watch inflight and limit in the byte_queue_limits for the queue.
inflight must always go back to zero when link goes idle.

> Thanks,
> Florian
