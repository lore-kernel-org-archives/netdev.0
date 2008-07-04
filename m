From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support
	for device classes.
Date: Fri, 4 Jul 2008 09:12:00 -0700
Message-ID: <20080704161200.GA1440@suse.de>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org> <m14p76ih9a.fsf_-_@frodo.ebiederm.org> <m1zloyh2mb.fsf_-_@frodo.ebiederm.org> <m1vdzmh2jr.fsf_-_@frodo.ebiederm.org> <m1r6aah2hh.fsf_-_@frodo.ebiederm.org> <m1mykyh2fu.fsf_-_@frodo.ebiederm.org> <m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com> <m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756772AbYGDQV6@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <486E2C3B.6020603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 04, 2008 at 10:57:15PM +0900, Tejun Heo wrote:
> Hello, Eric.
> 
> Eric W. Biederman wrote:
> > Thank you for your opinion.
> > 
> > Incremental patches to make things more beautiful are welcome.
> > 
> > Please remember we are not building lisp.  The goal is code that works today.
> > 
> > Since we are not talking about correctness of the code.  Since we are not
> > talking about interfaces with user space.  Since we are talking something
> > that is currently about 100 lines of code, and so will be easy to change
> > even after it is merged.   I don't understand how discussing this further
> > is useful.  Especially when I get a NAK  based on the feel that the code
> > is ugly.
> 
> I'm sorry if I gave you the impression of being draconian.  Explanations
> below.
> 
> > As for your main objection.  Adding a accessor method to an object versus
> > adding a data field that contain the same thing.  The two are effectively
> > identical.  With the practical difference in my eyes that an accessor method
> > prevents data duplication which reduces maintenance and reduces skew problems,
> > and it keeps the size of struct kobject small.  Since you think methods are
> > horrible I must respectfully disagree with you.
> 
> Yeah, it seems we should agree to disagree here.  I think using callback
> for static values is a really bad idea.  It obfuscates the code and
> opens up a big hole for awful misuses.  Greg, what do you think?

Sorry, Greg is walking out the door in 30 minutes for a much needed week
long vacation and can't look into this right now :(

I'll be able to review it next weekend, sorry for the delay.

greg k-h
