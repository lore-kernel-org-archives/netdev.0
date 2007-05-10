From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 10 May 2007 16:00:53 -0400
Message-ID: <1178827253.4062.78.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D10DA3@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Zhu, Yi" <yi.zhu@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:12993 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760314AbXEJUA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:00:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so657737wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:00:56 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902D10DA3@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 11:22 -0700, Waskiewicz Jr, Peter P wrote:
> > Wireless offers a strict priority scheduler with statistical 
> > transmit (as opposed to deterministic offered by the linux 
> > strict prio qdisc); so wireless is not in the same boat as DCE.
> 
> Again, you're comparing these patches with DCE, which is not the intent.
> It's something I presented that can use these patches, not as a
> justification for them.

I was making the claim that wireless _does not_ need you sawing off then
on the core code. It will work just fine with a prio qdisc. And the more
i think about it, the less i think DCE needs it ...

> I ran some tests on a 1gig network (isolated) using 2 hardware queues,
> streaming video on one and having everything else on the other queue.
> After the buffered video is sent and the request for more video is made,
> I see a slowdown with a single queue.  

What does this mean?

> I see a difference using these patches to mitigate the impact to the different flows; 

Thats is an extremely strong statement to be making. We need your
patches to get effective qos?

> Linux may be good
> at scheduling, but that doesn't help when hardware is being pushed to
> its limit - this was running full line-rate constantly (uncompressed mpg
> for video and standard iperf settings for LAN traffic).

What qdisc did you use on the single hardware queue? What was the
classifier you used to separate the video from the rest?
Why do i get the feeling that you did not configure Linux to give you
the separation needed?  If you want to do it proper i can help. 
I will chop off the rest of the text below because imo you need to
compare apples to apples and we are not getting anywhere.

Ok, how do we make progress forward? It seems to me we are back to
square one where i dont see a meeting in the middle.

I wanted to help, but you are so persistent on selling your patches that
we are loosing track of the discussion.
I strongly disagree with your approach and you strongly agree with your
patches. Maybe i should drop off this conversation and you can go
convince Dave? 

cheers,
jamal

