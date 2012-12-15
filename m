From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 16:44:56 -0800
Message-ID: <CA+55aFw-D2J-S8gH0PxO52nDeK31KHxum2gfT8RrzRoNF93yrg@mail.gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
 <CA+55aFyT5b9GmGX0kzMPQG795uojiiWjWxUBBG_-m9bfrThU=Q@mail.gmail.com> <20121215003844.GA10508@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:39386 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOApS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 19:45:18 -0500
In-Reply-To: <20121215003844.GA10508@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 4:38 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
>
> No need, I think.  Since its a user configurable choice now, the user can just
> set the selector to "None" in proc, and none will be used.

Well, by the same logic, there's no point to defaulting to MD5 either,
since the user could just put MD5 in the there.

The point is, if you're asking for a default, you should include the
actual choices, and not limit it to some random subset of choices. No?

             Linus
