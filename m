From: James Carlson <carlsonj@workingcode.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP 	multi-link
Date: Fri, 26 Mar 2010 13:04:24 -0400
Message-ID: <4BACE918.7020508@workingcode.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>	 <20100326160226.0159ac3b@lxorguk.ukuu.org.uk> <v2v2d460de71003260939w4877df7em9e3084a315b0962f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Richard Hartmann <richih.mailinglist@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <v2v2d460de71003260939w4877df7em9e3084a315b0962f@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Hartmann wrote:
> Also, I am not sure if it would not be better to default to no
> fragmentation and enable it optionally. I am aware that changing default
> behaviour is always a bit of a problem but to the best of my knowledge
> enabling fragmentation is a bug in any and all real-world applications.

It worked well and was enabled by default on all the Bay Networks
equipment I used ~15 years ago.  And I know for certain that we tested
with other gear (Ascend and Clam, probably) that did it right.

If it works with the equipment you're using, it's a useful feature in
that it can balance out the latencies among the links, resulting in much
lower overall latency observed by higher layers -- especially so on
lower-speed links where MP is more likely to be used.  Without it,
you're left either waiting for the one slow link choking on a big packet
to catch up, or (worse) disabling the sequence headers altogether,
resulting in reordering unless you're really "clever."

It's a darned shame that lame implementations would force a change in
the default ...

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
