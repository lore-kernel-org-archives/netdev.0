From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 20:12:29 -0500
Message-ID: <20121215011229.GD10508@neilslaptop.think-freely.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
 <CA+55aFyT5b9GmGX0kzMPQG795uojiiWjWxUBBG_-m9bfrThU=Q@mail.gmail.com>
 <20121215003844.GA10508@neilslaptop.think-freely.org>
 <CA+55aFw-D2J-S8gH0PxO52nDeK31KHxum2gfT8RrzRoNF93yrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46119 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOBMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 20:12:46 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFw-D2J-S8gH0PxO52nDeK31KHxum2gfT8RrzRoNF93yrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 04:44:56PM -0800, Linus Torvalds wrote:
> On Fri, Dec 14, 2012 at 4:38 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> >
> > No need, I think.  Since its a user configurable choice now, the user can just
> > set the selector to "None" in proc, and none will be used.
> 
> Well, by the same logic, there's no point to defaulting to MD5 either,
> since the user could just put MD5 in the there.
> 
> The point is, if you're asking for a default, you should include the
> actual choices, and not limit it to some random subset of choices. No?
> 
>              Linus
> 
Ok, Thats a fair point, I can add a option to choose the "None" option as the
deafult.  Dave, do you want a delta patch, or a new version?
Neil
