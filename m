From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Fri, 19 Jun 2009 15:51:00 -0700
Message-ID: <43e72e890906191551j1a201a87u4fcccb15ec961762@mail.gmail.com>
References: <20090615214735.GE23972@bombadil.infradead.org>
	<20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org>
	<20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla>
	<20090616093401.GA11602@jm.kir.nu> <20090616181705.GB31506@tesla>
	<20090619150015.GC1389@ucw.cz> <43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com>
	<20090619221909.GC2229@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	Greg KH <greg@kroah.com>, "corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:49635 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110AbZFSWvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 18:51:18 -0400
In-Reply-To: <20090619221909.GC2229@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2009 at 3:19 PM, Pavel Machek<pavel@ucw.cz> wrote:
>
>> >> +2.0.2: RC-SERIES RULES
>> >> +
>> >> +Rules on what kind of patches are accepted after the merge window closes.
>> >> +These are patches targeted for the kernel rc-series of a kernel prior
>> >> +to its release.
>> >> +
>> >> + - it must fix a reported regression
>> >> + - it must fix a reported security hole
>> >> + - it must fix a reported oops/kernel hang
>> >
>> > - it must fix a bug.
>>
>> Well that's for certain, but there is a difference between a general
>> notion of a bug and the type of bug fixes that should go in during the
>> rc-series. This documentation patch highlights the difference.
>
> Yes, and I'm trying to tell you that this documentation patch is
> wrong.

This mean you might be able to help correct this.

> Non-intrusive bugfixes _are_ welcome after -rc1.

That's great news to me.

I think it would really help to get a clarification on what is meant
by "non-intrusive bugfixes" though. Can you elaborate on that?

>> > Non-intrusive bugfixes too, afaict.
>>
>> It really depends on what you mean but generally no, and this is why I
>> think this clarification is important.
>
> I believe you are wrong.

I was actually hoping I would be. But I'd like some confirmation that I am.

For example, based on your feedback we have a series of fixes we'd
like to try to get merged for 2.6.31-rc2 for ath9k. I have been under
the impression that since those fixes do not meet the criteria
clarified by my original patch on documentation for the rc-series that
they would not get merged and our only option to get users to get
these patches is to wait for 2.6.32 or use some sort of bleeding edge
backport package. We try hard to get out our patches in time prior to
the merge window but sometimes some patches don't manage hit that
timeline so if you tell me we can certainly send "non-intrusive bug
fixes" post rc1 then that is what we will try to do. I just do not
want to get bitch slapped about it when we do.

  Luis
