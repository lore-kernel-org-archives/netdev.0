From: Jason Lunz <lunz@falooley.org>
Subject: Re: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 15:13:30 -0400
Message-ID: <20060721191329.GA15478@knob.reflex>
References: <20060721185945.GA7611@suse.de> <200607212103.23954.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Hering <olh@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:49542 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S1751114AbWGUTNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 15:13:35 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200607212103.23954.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 09:03:23PM +0200, Michael Buesch wrote:
> I am not going to maintain a bogus version number.
> What about simply returning 1.0 and be done with it.
> I don't think it matters. 1.0 is as bogus as any other value.

Put it to use! Increment it whenever there's a major change in the
driver, like the locking rewrite or the init routine rewrite. At the
very least, it makes it easier to rule certain things out if a user
reports lockup or something.

Jason
