From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: Traffic shaping - class ID 16bit limit?
Date: Thu, 25 Aug 2011 18:28:01 +0200
Message-ID: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38656 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab1HYQ2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 12:28:02 -0400
Received: by qwk3 with SMTP id 3so1419046qwk.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 09:28:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

the question is simple: What should I do if I need to have more than
2^16 subclasses of a classful queuing discipline (in, say, hfsc or
htb)?

I bumped into this problem while writing some kind of traffic shaping
software and thinking about scalability. As there still are other ways
to have more than 64k "classes" (like grouping some subclasses into
separate qdiscs), those ways have significant drawbacks (require more
tc-filter rules and decisions, generally more processing power, and
the structure is quite hard to maintain).

Technically the ClassID seems to be "hardcoded" as a 16bit value, but
after some source searching, I haven't found any good reason for it to
be 16-bit only.

I understand that those ID's are usually handled together with another
16bit Qdisc ID, which would add up to a quite big number (possibly
unpleasant on some architectures) if those were both 32bit.

I also completely understand that in most cases of common usage
there's absolutely no need to have this big amount of subclasses, but
on the other hand there's still no reason to have "64k classes enough
for everyone". :D

Of course if there's some obvious method to solve this, or a patch, or
some kind of workaround that I haven't found, please let me know about
it, I will happily use it.

Thanks for any suggestions,
Mirek Kratochvil
