From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Fri, 21 Feb 2014 10:37:42 +0600
Message-ID: <20140221043741.GI30109@kumar-pc.asicdesigners.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
 <1392726375-32001-2-git-send-email-hariprasad@chelsio.com>
 <53051E48.9050901@opengridcomputing.com>
 <53064459.3030106@chelsio.com>
 <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
 <5306548A.2090406@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hariprasad Shenai <hariprasad@chelsio.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, <dm@chelsio.com>,
	<nirranjan@chelsio.com>, <santosh@chelsio.com>
To: Casey Leedom <leedom@chelsio.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30425 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752603AbaBUFg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 00:36:26 -0500
Content-Disposition: inline
In-Reply-To: <5306548A.2090406@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, February 02/20/14, 2014 at 11:16:26 -0800, Casey Leedom wrote:
> 
> On 02/20/14 11:00, Florian Fainelli wrote:
> >2014-02-20 10:07 GMT-08:00 Casey Leedom <leedom@chelsio.com>:
> >>On 02/19/14 13:12, Steve Wise wrote:
> >>>
> >>>You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as
> >>>part of this series.
> >>
> >>   I'm ~pretty sure~ that the "word on the street" was that the community
> >>wanted to get away from the SPEED_XXX symbols since they simply represented
> >>the values XXX.  Thus they didn't offer any real symbolic isolation from
> >>weird constants, etc.  I believe that the old SPEED_XXX values were left in
> >>place in order to avoid making tons of changes everywhere ...
> >Not quite sure where and when you heard that, it seems a little
> >disturbing to add a comment in this patch saying "this I how I should
> >fix things" and not do them, especially when this is a one-liner.
> >Having a well defined constant is easier to grep than having the
> >open-coded 40000 constant which will lead to false positives
> >throughout the tree.
> 
>   Like I said, it was a vague memory at best from over a year ago. I
> seem to remember someone on our team trying to push SPEED_40000 into
> the kernel and getting rebuffed.  Perhaps I didn't have enough
> coffee that day.
> 
>   In any case, I personally like the idea of SPEED_40000 for exactly
> the reason you offer: I can search for it meaningfully.  So If my
> vague memory is wrong, yeay!


BTW, I just now found below thread and discussion related to SPEED_40000
http://www.spinics.net/lists/netdev/msg201449.html


> 
> Casey
> 
> >--
> >Florian
> 
> 
