From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 07:36:49 +0100
Message-ID: <20110311063649.GA13293@elte.hu>
References: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
 <20110310.155556.48513201.davem@davemloft.net>
 <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
 <20110310.163434.260095615.davem@davemloft.net>
 <AANLkTimAPqTYT_j6t3cT32WfD6cQPySG0tnQVhC8Z=NO@mail.gmail.com>
 <20110311033406.GA11004@home.goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110311033406.GA11004@home.goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu, Mar 10, 2011 at 04:51:34PM -0800, Linus Torvalds wrote:
> > 
> > The reasons can be any of:
> > 
> >  - "I don't want to get too far away from upstream". This is very
> > understandable, but I have asked people to please _not_ merge "random
> > trees of the day". Please use major releases for this (or, if worst
> > comes to worst, -rc releases) rather than just do something else.
> 
> What are you throughts on starting work from a tree. Most of my work is usually 
> based off of some branch in tip, but sometimes when I'm pulling in patches that 
> are not really related to anything, I just simply grab whatever the latest Linus 
> branch is and start from there.
> 
> Is it preferable to instead start from one of the official releases?

Yes, for clarity of merge history i'm generally asking all people who send pull 
requests to -tip to use official -rc's as bases (or -tip branches), *not* some 
random daily -git snapshot. If a -git snapshot has to be merged for a good reason 
then please amend the merge commit with the Merge-Reason tag describing the good 
reason you had.

Thanks,

	Ingo
