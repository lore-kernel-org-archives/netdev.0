From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 3/3] nl80211: Various checkpatch.pl fixes
Date: Mon, 30 May 2016 10:35:39 +1000
Message-ID: <CAGRGNgWMxU3qBsr0eu5cdAstu+s-0b9p1r-z5ZvkYejv2GtQLA@mail.gmail.com>
References: <cover.1464492195.git.kirtika.ruchandani@gmail.com> <5c2861995f05d456b3ce16e29ceae7e578b1456f.1464492195.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	ruchandani.tina@gmail.com, netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33221 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbcE3Af7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 20:35:59 -0400
In-Reply-To: <5c2861995f05d456b3ce16e29ceae7e578b1456f.1464492195.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kirtika,

On Sun, May 29, 2016 at 1:31 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
> This patch fixes the following checkpatch.pl issues -

There's too much stuff here to quickly review, it'd be nice if you
could split this up into patches that do the following:

Space issues:
> - space preferred around that <operator>
> - no space needed after cast.
> - Alignment should match open parenthesis
> - suspect code indent for conditional statements
> - Statements should start on a tabstop

Braces:
> - braces {} should be used on all arms of this statement

Multiple assignments:
> - multiple assignments should be avoided

ether_addr_copy:
> - prefer ether_addr_copy over memcpy

Spelling:
> - correct spelling - 'implementation'

NULL comparisons:
> - comparison to NULL could be written as !foo

kcalloc vs kzalloc:
> - prefer kcalloc over kzalloc with multiply

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
