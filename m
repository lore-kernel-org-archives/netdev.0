From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Mon, 2 Nov 2009 11:07:02 +0100
Message-ID: <20091102100702.GA16963@elte.hu>
References: <1256886023.3555.5.camel@johannes.local> <20091030110616.GB6150@ff.dom.local> <20091030150223.GA2586@tuxdriver.com> <20091102091038.GA9044@elte.hu> <1257153807.3555.173.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754829AbZKBKLq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1257153807.3555.173.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Johannes Berg <johannes@sipsolutions.net> wrote:

> On Mon, 2009-11-02 at 10:10 +0100, Ingo Molnar wrote:
> 
> > So i have read the thread you and Bartlomiej referenced:
> > 
> >     http://lkml.org/lkml/2009/10/17/81
> > 
> > ... and my understanding of that discussion is very different from 
> > yours. Here is my annotated history of the beginnings of that 
> > discussion:
> 
> [snip]
> 
> You shouldn't ignore all previous interaction between Bart and us -- 
> which wasn't pretty: http://thread.gmane.org/gmane.linux.kernel/901892

I have seen that exchange too - here's the lkml.org link for those who 
like the lkml.org format:

   http://lkml.org/lkml/2009/10/13/186

And i can see no supporting fact here either, for the (very serious) 
accusation launched by John Linville, that Bartlomiej is 'petty, 
whining, indignant'. In my reading he is the opposite of that, even in 
this second thread you point out.

So, no matter how much you disagree about the code and its direction, 
please either back up your assertion with specific links to a pattern of 
misbehavior or apologize for the ad-hominen attacks against Bartlomiej.

> Of course we were biased when he came around with that petty code 
> duplication argument, since it seemed to support only his agenda of 
> working only with the staging drivers.

Why do you think that disagreeing in the past gives you the right to get 
into ad-hominens? You should concentrate on the code and on the 
technical side, not on the person making the argument.

Also, why do you characterise a code duplication argument as 'petty'?

Bloat and unnecessary technical forking is the #1 enemy of Linux. 
Integrating code and infrastructure is the #1 strength of Linux.

Upstream subsystems/drivers running away with their private 
implementations has its clear costs:

 - introduces bugs
 - makes drivers shallow in practice 
 - makes unifying drivers and infrastructure so hard down the road
 - bloats the code, increases i$ footprint

I routinely refuse patches based on 'please dont duplicate' arguments, 
in fact i did it once today already.

[ I dont know why drivers/staging/ is even an argument here - he argued
  about the technical qualities of a new upstream driver, not about a
  staging driver. Upstream drivers are to be held to higher standards,
  _especially_ now that we can isolate not-clean-enough-yet drivers into
  drivers/staging/, without hurting users. ]

Thanks,

	Ingo
