From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
	resetting -> dead NIC
Date: Thu, 19 Mar 2009 19:19:11 +0100
Message-ID: <20090319181911.GB30702@lxbsc01>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net> <20090319180644.GA30702@lxbsc01> <20090319181536.GA13368@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:46917 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbZCSSTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:19:17 -0400
Content-Disposition: inline
In-Reply-To: <20090319181536.GA13368@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 11:15:36AM -0700, Matt Carlson wrote:

> > Would switching the uplink connection to eth1 (and not use eth0 in
> > Linux) give some more clue as well?
> Sure, let's try that.  Maybe this is the better way to go anyways.  I just
> learned that disabling iLo2 doesn't necessarily disable the management
> firmware on the network device.
> 
> For this to be a meaningful test though, we need to verify that the
> driver sign-on messages have a line that reads "ASF[0]" on eth1.  Can
> you confirm?

Yes:

[1186598.218205] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1]
WireSpeed[1] TSOcap[1]
[1186598.281314] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0]
WireSpeed[1] TSOcap[1]

I'll keep the traffic on eth0 now until it breaks again, hopefully
spewing out more debugging info with your patch and then I'll switch to
eth1.

Bernhard
