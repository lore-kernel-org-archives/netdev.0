From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: IPsec AH use of ahash
Date: Sat, 19 Jan 2013 03:33:55 +0100
Message-ID: <20130119023355.GB10964@lion>
References: <20130118221614.GA5616@ppwaskie-mobl2.amr.corp.intel.com>
 <1702471741.91455.1358548305936.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1702471741.91455.1358548305936.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 05:31:45PM -0500, Tom St Denis wrote:
> My gripe here is suppose I spend professional paid time working on an
> AH patch to [in my opinion] fix it and then I get
> ignored/stonewalled/etc because I didn't cross a t or dot an i ...
...
> ... if the likelihood of seeing it in mainline is basically around 0%.

You received a detailed response from subsystem maintainer who is an
extremely busy man; that doesn't look like ignoring to me. And as for
stonewalling, I don't see anything like that either. You were just told
what is wrong and asked to send a fixed version. Once you do that, the
chances of the patch to be accepted are actually very high.

Yes, kernel rules for submitting and coding style may seem too strict at
the first glance. But there is a good reason for them: linux kernel is
huge and without strict rules it would be one big mess. Part of my work
consists of resolving bugs in various software projects, often these are
projects the sources of I have never seen before. And I wish more (or
rather as many as possible) had rules similar to the kernel because
looking for something in code which is badly structured and lacks
unified coding style, in project without good and descriptive commit
description, can be a terrible experience.

You may call it nitpicking and mock it, you may even feel offended, but
the open source world would be much better place to live in if other
projects had rules similar to linux kernel (and its networking in
particular).

> It would have taken them very little time to merge the patch I sent
> in, fix the (), maybe address some of the coding style "errors" and
> then form a patch for mainline based on that.  Don't you think I have
> better things to do than re-submit working code repeatedly?

So you consider your time too precious to conform to the kernel coding
style and, on the other hand, the time of subsystem maintainers totally
worthless so that you feel it is their job to tidy up your patches?

Someone already pointed you to http://patchwork.ozlabs.org/
Please do take a look there. I just did and found that in last three
months, about 3500 patches were submitted to this list, i.e. about
40 patches per day (including weekends and Christmas). All of these need
to be reviewed by a few maintainers who are also doing their part of
development. How do they manage to handle it, honestly I don't know.
And then you come and tell us they should also fix coding style and
obvious mistakes for everyone who is too lazy to do it themselves.
Don't you think it would be much more effective if we tried to make
their work easier rather than put more work on their shoulders?

> Ok but as "maintainers" they should be "maintaining" code ... if
> coding standards change (and btw the XCBC code was likely submitted
> long after the coding standards were put in place) then the
> maintainers should go through code they're responsible for and update
> it.

Fixing the wrong coding style of existing code would be definitely
useful but unlike reviewing patches, fixing bugs and developing
features, it doesn't require detailed knowledge of the code. Using
highly skilled and experienced developers (which is who subsystem
maintainers are), that would be a real wasting of resources.

> "xcbc.c" for instance was last touched in 2011.  It hasn't been
> maintained at all apparently.  There were a handful of patches against
> it ... none which address these "coding standards."

The fact that there are only few changes doesn't necessarily mean the
code is unmaintained. It can also mean that it works well and it doesn't
need new features or adjusting to new hardware or protocol versions. And
when the code doesn't change too often, the urge to fix its style is
rather low. But presence of old badly styled code doesn't justify
introducing more badly styled code.

                                                          Michal Kubecek
