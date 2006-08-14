From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] Remove ugly TODO output from log files in bcm43xx-softmac
Date: Mon, 14 Aug 2006 21:51:55 +0200
Message-ID: <200608142151.56340.mb@bu3sch.de>
References: <44DA4FF5.4020507@lwfinger.net> <20060814185456.GB13934@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49091
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751426AbWHNTwy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 15:52:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060814185456.GB13934@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 August 2006 20:55, John W. Linville wrote:
> On Wed, Aug 09, 2006 at 04:13:25PM -0500, Larry Finger wrote:
> > This patch removes the ugly TODO output from the logs for bcm43xx-softmac. 
> > The
> > patch is for the latest version of Linville's wireless-2.6 tree.
> 
> I'm not sure if this is the right approach.  In fact I know it isn't --
> the right approach would be to implement the missing code! :-)
> 
> But barring that, wouldn't it be better to change the TODO() macro
> to key off a build-time definition like CONFIG_BCM43XX_DEBUG?
> 
> Michael, what do you think?

Heh, well.
Actually the TODO define should have died since months.
BUT: There are still 11 uses of it and they are _all_ valid uses.
_None_ of these should be removed without implementing the code
at the same time.

So, well. What about compiling it to a no-op if BCM43XX_DEBUG is
not defined. I think this is a bad idea.
These TODOs are there for a _very_ good reason. They say:
"If you see this in dmesg, feature foobar does not work at all".
They are a very good hint to the user (and escpecially to the
developers when dealing with "bugreports").

So: If someone would like that a TODO disappears in the logs,
go forward and implement the code. (Actually, most TODOs are
there because of incomplete specifications. But that might have
changed inbetween).

-- 
Greetings Michael.
