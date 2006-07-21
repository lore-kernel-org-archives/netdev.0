From: Michael Buesch <mb@bu3sch.de>
Subject: Re: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 21:27:23 +0200
Message-ID: <200607212127.23786.mb@bu3sch.de>
References: <20060721185945.GA7611@suse.de> <200607212103.23954.mb@bu3sch.de> <20060721191329.GA15478@knob.reflex>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Olaf Hering <olh@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:8587
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750859AbWGUT3C
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 15:29:02 -0400
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20060721191329.GA15478@knob.reflex>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 July 2006 21:13, Jason Lunz wrote:
> On Fri, Jul 21, 2006 at 09:03:23PM +0200, Michael Buesch wrote:
> > I am not going to maintain a bogus version number.
> > What about simply returning 1.0 and be done with it.
> > I don't think it matters. 1.0 is as bogus as any other value.
> 
> Put it to use! Increment it whenever there's a major change in the

What is a major change? Why only on major change? Why not on
simple changes, too? Simple changes sometimes introduce bugs, too.

> driver, like the locking rewrite or the init routine rewrite. At the
> very least, it makes it easier to rule certain things out if a user
> reports lockup or something.

What I wanted to say: I _never_ had debugging-problems, because
I did not know the source state it was compiled from.

If there is a lockup, and I don't see if a specific change
that might cause it is in or not, I simply ask him. It's _much_
easier than maintaining a bogus counter.

The version counter will cause patch hunks to fail and whatever.
It's only useless trouble.

If someone is not able to answer questions like:
"Which kernel version do you run?"
"Please look at foo.c line 234 and tell me what's there."
He does not want to debug the problem anyway. Problem solved.
Someone else will appear to help debugging it, if it's a real bug.

-- 
Greetings Michael.
