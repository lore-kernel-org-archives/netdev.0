From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: suspicious logic in tcp_make_synack()
Date: Mon, 27 Oct 2008 08:51:19 -0700
Message-ID: <396556a20810270851x18ad55c6sd690457af6616224@mail.gmail.com>
References: <20081026.010158.193698298.davem@davemloft.net>
	 <20081026174147.GB27584@Chamillionaire.breakpoint.cc>
	 <20081026.231102.214077979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:44336 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbYJ0PvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 11:51:21 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2191454rvb.1
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 08:51:20 -0700 (PDT)
In-Reply-To: <20081026.231102.214077979.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2008 at 11:11 PM, David Miller <davem@davemloft.net> wrote:
> I can't count on my two hands how many bugs were caused by that one
> single commit :-(

I should have made more of an effort to keep up with netdev during the
.27 release, rather than just the rc's, so I fear that I didn't see
all the bugs. I'll go though the archives today.

Although that commit was born of an attempt to save some people from
some of the pitfalls of modifying the previous code it clearly wasn't
something that I should have attempted. The cost of newbies touching
code in that area is too great both in tickling bugs in other systems
(with option ordering) and in stupid omissions like this. It's
probably been too long to revert it wholesale now, so I can only
attempt to be more parsimonious in the future and hope that that's the
last of the pain. If nothing else, suspicion of that commit has
probably been raised to such a level that competent folks have checked
it all over now.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
