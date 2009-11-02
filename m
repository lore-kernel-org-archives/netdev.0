From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Mon, 2 Nov 2009 10:10:38 +0100
Message-ID: <20091102091038.GA9044@elte.hu>
References: <1256886023.3555.5.camel@johannes.local> <20091030110616.GB6150@ff.dom.local> <20091030150223.GA2586@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754095AbZKBJKt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091030150223.GA2586@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* John W. Linville <linville@tuxdriver.com> wrote:

> On Fri, Oct 30, 2009 at 11:06:16AM +0000, Jarek Poplawski wrote:
> 
> > There are various ways to disagree, and ignoring by John questions
> > from a merited developer both in this referenced lkml and current
> > threads looks at least strange (if not offensive) as well.
> 
> Did you read the thread for which Bartlomiej provided a link earlier? 
> There were ten responses (only three of them from him) in that thread. 
> His comments were not ignored, they were rejected.
> 
> Ever since Bartlomiej decided to tear himself away from 
> drivers/staging, he has been nothing but negative -- petty, whining, 
> indignat, whatever.  Just what has he done to merit any special 
> consideration here?  Why should he have any sort of veto over rt2x00?

I got curious, as my past experience with Bartlomiej is that he is a 
factual, reliable, knowledgable upstream driver developer interested in 
difficult pieces of code others are reluctant to touch, for whom it is 
rather atypical to get 'petty, whining, indignant'.

So i have read the thread you and Bartlomiej referenced:

    http://lkml.org/lkml/2009/10/17/81

... and my understanding of that discussion is very different from 
yours. Here is my annotated history of the beginnings of that 
discussion:

Bartlomiej (in <200910171654.03344.bzolnier@gmail.com>) started his 
review of the driver with:

 | First let me say that I'm very happy to see this patch finally being 
 | submitted and I appreciate the effort..
 |
 | (I'll give it a spin on Eee 901 w/ 2.6.32-rc5 sometime later..)

Very friendly and constructive. Pretty much the Bartlomiej i have known 
for years.

Then he continues with his technical observations:

 | Now to the less happy part..
 |
 | I also used the opportunity to take a closer look at this driver and 
 | it seems that it needlessly adds around 2 KLOC to kernel by 
 | duplicating the common content of rt2800usb.h to rt2800pci.h instead 
 | of moving it to the shared header (like it is done in the staging 
 | crap drivers):
 |
 | [...]
 |
 | All in all, the total amount of the kernel code needed for 
 | implementing rt2800pci functionality should 1-2 KLOC instead of the 
 | current 5 KLOC.

Looks like a valid technical point that should be replied to in ernest.

Johannes Berg's first reply (<1255792104.3434.2.camel@johannes.local>) 
ignored Bartlomiej's friendly approach and launched a combative, 
emotion-laden, unconstructive (and technically inapposite) attack:

 | Tell me you're kidding -- comparing 2k duplicated LOC with a driver 
 | that ships its own wifi stack?

Bartlomiej's reply (<1255792104.3434.2.camel@johannes.local>) ignored 
the attack (gracefully) and replied to the technical portion only:

 | > Tell me you're kidding -- comparing 2k duplicated LOC with a driver 
 | > that ships its own wifi stack?
 |
 | Why would I be?
 |
 | 1) The patch is submitted to kernel _proper_ not kernel staging so I 
 | see no excuse for duplicating 2-4 KLOC and it should be fixed.
 |
 | 2) The fact that the some staging driver consists in 90% of crap 
 | doesn't mean that it doesn't have some good design ideas..  (i.e. 
 | abstracting chipset registers access in a discussed case)

To which technical point Johannes elected not to reply. (Effectively 
conceding Bartlomiej's point as per lkml discussion rules.)

[ There are similar patterns in other threads of this discussion - the 
  reply in (<200910181859.22413.IvDoorn@gmail.com>) and followups 
  were similarly dismissive (while not as combative as Johannes's reply) 
  - with an often offensive tone against Bartlomiej. ]

Bartlomiej followed up with his test results in another message in 
<200910172318.56929.bzolnier@gmail.com>. Corroborated by Luis Correia in 
<efe7343f0910180240o223ac346j3dd7c45c7460ec41@mail.gmail.com>. Both 
messages were factual, constructive and friendly.

Neither failure report was replied to in that thread and remains ignored 
up to today, 15 days down the line.

Alas, the portion of the story that is visible in that discussion on 
lkml contradicts your claim almost 180 degrees. The person being 
attacked there was Bartlomiej and i simply dont see where you got the 
conclusion from that he was 'petty, whining, indignant'.

Now look at the aftermath from Bartlomiej's perspective: this 
non-working driver with arguably unresponsive, unfriendly maintainers 
got pulled twice (first by you and then by David), and it is now on the 
unstoppable path upstream. By omission he's been forced to raise these 
issues at every hop that pulls this piece of code - and it was not his 
choice to be exposed to such a spiral of a workflow.

I can understand David trusting your judgement and not wanting to get 
involved in the fine details, but having read the surrounding discussion 
i dont understand your interpretation of the events, and i dont 
understand on what basis you launched your very serious accusation, that 
he is being 'petty, whining, indignant'. Every reply from him in that 
thread is the exact opposite of that. Care to elaborate?

Thanks,

	Ingo
