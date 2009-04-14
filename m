From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Tue, 14 Apr 2009 11:29:22 -0700
Message-ID: <20090414182922.GB12475@xw6200.broadcom.net>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
 <20090315143214.90c71fb7.akpm@linux-foundation.org>
 <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de>
 <20090319165842.GA10819@xw6200.broadcom.net>
 <20090322132121.GA7871@pest>
 <20090331162617.GB15533@xw6200.broadcom.net>
 <20090331221621.GA1324@schleppi.birkenwald.de>
 <49E3B4A0.8040009@birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4948 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758786AbZDNS3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 14:29:33 -0400
In-Reply-To: <49E3B4A0.8040009@birkenwald.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2009 at 02:54:40PM -0700, Bernhard Schmidt wrote:
> Hi Matt,
> 
> >>> I'm now switching to eth1.
> >> Bernhard, any word on what happened?
> > 
> > So far so good. In the last week my watchdog (cannot reach the default
> > gateway) triggered once, but since there were no "PCI Memory Mapped IO
> > Disabled!!!!" messages in the logfile I assume that was a real network
> > problem. Since the box ran fine for months initially and the first two
> > occurances of this issue were two weeks apart I cannot say for sure, but
> > it definitely feels better than the "once in two days" in the end.
> 
> No crashes in the last two weeks.
> 
> Do you have any further suggestions how to debug this or should we 
> accept that portsharing doesn't work very well? This is the second 
> problem we can directly attribute to the sharing with the iLO (the first 
> one being the "no IPv6 unless the port is in promiscous mode", we had a 
> thread about this here on netdev a few months ago).

No, I think we need to get this to work with portsharing.  We just need
to figure out what it is about it that causes these types of errors.

I talked to the firmware maintainer here.  We have a couple ideas that
might uncover what is happening.  Our next step is to develop a set of
tests that will show under what assumptions the firmware is operating.
Once we have that, I'll ask you to patch your driver so that we can see
what is happening from your end.

Stay tuned.

