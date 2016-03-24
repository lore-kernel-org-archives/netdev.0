From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 07:12:22 +0100
Message-ID: <20160324061222.GA6807@1wt.eu>
References: <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151216073814.GA3373@1wt.eu>
 <20151216161514.GA3476@1wt.eu>
 <CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
 <20151218185812.GD4448@1wt.eu>
 <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151219070009.GA4634@1wt.eu>
 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
 <20151221204127.GC8018@1wt.eu>
 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:31487 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbcCXGMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 02:12:38 -0400
Content-Disposition: inline
In-Reply-To: <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Mar 23, 2016 at 10:10:06PM -0700, Tolga Ceylan wrote:
> I apologize for not properly following up on this. I had the
> impression that we did not want to merge my original patch and then I
> also noticed that it fails to keep the hash consistent. Recently, I
> read the follow ups on it as well as Willy's patch/proposals.
> 
> Is there any update on Willy's SO_REUSEPORT patch? IMHO, it solves the
> problem and it is simpler than adding new sock option.

no, Craig's changes were merged, and I haven't checked yet if my patch
needs to be rebased or still applies. Feel free to check it and resubmit
if you have time.

Best regards,
Willy
