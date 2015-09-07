From: Felix Kaiser <felix.kaiser@fxkr.net>
Subject: Re: [PATCH] ip link/addr show: add empty line between interfaces
Date: Mon, 07 Sep 2015 17:38:48 +0200
Message-ID: <1441639971-sup-8473@zero>
References: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net> <20150907144609.3ec9f4d0@griffin>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37126 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbbIGPiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 11:38:52 -0400
Received: by wicfx3 with SMTP id fx3so87771217wic.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 08:38:50 -0700 (PDT)
In-reply-to: <20150907144609.3ec9f4d0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Excerpts from Jiri Benc's message of 2015-09-07 14:46:09 +0200:
> Or makes the readability worse by requiring more scrolling, depending
> on number of interfaces you have and your taste.

Of course it's slightly subjective, but I think it improves readability
quite a bit *especially* on servers with many interfaces.

Without the additional lines, you can obviously fit more on one screen,
but I don't think it's much, and I think that once you have a screenful
of text, adding some whitespace makes it much, much easier to focus on
the individual sections.

> Many users prefer the current format.

I've met users who prefer ifconfigs format (and have literally told me
that they find ips hard to read), and I've met users who use a shell
alias to hack newlines in (which is the motivation for this patch), and
everyone that I've shown side-by-side comparisons has been supportive.

> Also, as sad as it is, there are scripts out there that parse ip output
> and I have no doubts this would break them.

I'm aware.

My opinion is that if someone parses that, they deserve the opportunity
to fix their code. At the very least they could have used -oneline!

The default output format is clearly intended for humans; it seems
like no attention at all has been given to parseability. And that's
as it should be - since, because it requires the fewest keystrokes,
that's the format that nearly all interactive users are going to see,
and the output should be optimized for them.

If absolute compatibility even for badly written scripts that misuse
the tool had to be maintained then that'd mean that no improvements
could ever be made, and that'd be sad.

Felix
