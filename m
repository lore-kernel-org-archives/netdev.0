From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for rc-series and merge window
Date: Tue, 23 Jun 2009 20:52:02 +0200
Message-ID: <m3bpoen5pp.fsf@intrepid.localdomain>
References: <20090622222217.GH23972@bombadil.infradead.org>
	<m3fxdqj2bz.fsf@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	torvalds@linux-foundation.org, Pavel Machek <pavel@ucw.cz>,
	Greg KH <greg@kroah.com>, "corbet\@lwn.net" <corbet@lwn.net>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm\@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan\@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata\@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Jake Edge <jake@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50627 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbZFWSwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 14:52:03 -0400
In-Reply-To: <m3fxdqj2bz.fsf@lwn.net> (Jake Edge's message of "Tue\, 23 Jun 2009 11\:18\:40 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jake Edge <jake@lwn.net> writes:

>> +After the merge window the kernel is worked on through the rc-series of the
>> +kernel release. The rc-series focus is to address regressions. The merge window
>> +closes upon the first rc-series release, rc1.
>
> to address regressions and fix bugs introduced by the new features added
> during the merge window.

I would say, to address regressions and fix bugs. Not only those added
recently, though obviously older bugs should have already been fixed.

>> +After a subsystem maintainer has sent his pull request to Linus during the merge
>> +window no further new development will be accepted for that
>> +foo-next-2.6.git

This is IMHO uncertain. Typical, but uncertain. I guess the maintainer
would already know what to do so I'm not sure there is a point to write
it down in this file.

> It doesn't seem like you need to keep stressing that the merge window
> closes with -rc1 ... but maybe that's just me ...

Me2 :-)

>> +Non-intrusive bug fixes fixes will very likely not be accepted.
                      ^^^^^^^^^^^
I guess it depends on many factors, such as importance of the bug vs the
risk at the given point. Intrusive bug fixes are sometimes unavoidable
and there may be simply no better option than applying them at once.

> Again, maybe it's just me, but this 'non-intrusive' distinction doesn't
> read quite right ...

Me2 :-)

> I guess the problem is that non-intrusive and
> regression/security/oops fixes are not mutually exclusive

Precisely. This is about risk vs gain.

> so, when do these non-intrusive bug fixes get accepted?  only
> pre-merge window?

Doesn't make sense. Merge window = new features. Fixes can be accepted
anytime (this obviously includes merge window).

>> +The very first release a new driver or filesystem is special. New drivers
>> +are accepted during the rc-series! Patches for the same driver then are
>> +also accepted during the same rc-series of a kernel as well as fixes for it
>> +cannot regress as no previous kernels exists with it.

Given that fixes are accepted anytime (well, almost, depending on risk
vs gain), then obviously fixes for new driver aren't worse.


Perhaps it's just me :-) but I think we're trying to codify the rules
way too much. The general rules (merge window = new features etc) are
obviously ok but why do we need strict details like intrusive vs
non-intrusive etc? People should just use a common sense and good
judgement and, if in doubt in some particular case, ask. We are unable
to describe all situations in a single text file.
-- 
Krzysztof Halasa
