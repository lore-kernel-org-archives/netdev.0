From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sun, 10 Dec 2006 14:27:20 +0100
Message-ID: <200612101427.20817.mb@bu3sch.de>
References: <1165654123.2816.29.camel@portland.localdomain> <20061209160640.GA3365@tuxdriver.com> <87hcw49rg8.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43905
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760515AbWLJN2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 08:28:13 -0500
To: Pavel Roskin <proski@gnu.org>,
	Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <87hcw49rg8.fsf@briny.internal.ondioline.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 December 2006 07:48, Paul Collins wrote:
> "John W. Linville" <linville@tuxdriver.com> writes:
> 
> > On Sat, Dec 09, 2006 at 03:48:43AM -0500, Pavel Roskin wrote:
> >> Hello!
> >> 
> >> Somebody please mark CONFIG_CFG80211 in wireless-dev.git as
> >> experimental/broken/incomplete/whatever.  Not only doesn't it work, but
> >> it also breaks Wireless Extensions if enabled, even if CONFIG_D80211 is
> >> disabled.
> >> 
> >> Driver developers should know that if they enable CONFIG_CFG80211 they
> >> won't be able to debug their drivers effectifely; they'll have to fix
> >> cfg80211 first.
> >
> > Perhaps you could be more specific?  I'm sending this to you from a
> > box booted on the current (~1 week old) wireless-dev kernel using a
> > WEXT-configured ipw2200 device.
> >
> > What problems are you experiencing?  CFG80211 shouldn't interfere w/
> > WEXT if a driver doesn't support it.
> 
> I think I hit this too when I started playing with wireless-dev a week
> or so ago.  I had CFG80211 enabled and iwconfig reported "wireless

Ehm, guys?
cfg80211 is not usable in its current form because there isn't
even a damn userspace tool to interact with nl80211.
So why don't you just disable the option for the time being? That's
not too hard, I guess, and it magically fixes _all_ of your problems.

Another optional possibility would be to _implement_ the cfg80211
in d80211 and the standalone drivers, so at least the compatibility
layer works.
Come on guys, get your hands dirty instead of talking bullshit about
development code.

-- 
Greetings Michael.
