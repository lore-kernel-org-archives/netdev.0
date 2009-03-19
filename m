From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Thu, 19 Mar 2009 11:15:36 -0700
Message-ID: <20090319181536.GA13368@xw6200.broadcom.net>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
 <20090315143214.90c71fb7.akpm@linux-foundation.org>
 <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de>
 <20090319165842.GA10819@xw6200.broadcom.net>
 <20090319180644.GA30702@lxbsc01>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4713 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753523AbZCSSQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 14:16:23 -0400
In-Reply-To: <20090319180644.GA30702@lxbsc01>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 11:06:44AM -0700, Bernhard Schmidt wrote:
> On Thu, Mar 19, 2009 at 09:58:42AM -0700, Matt Carlson wrote:
> 
> Hello Matt,
> 
> > Hi Bernhard.  I talked to Michael about this and we'd like you to try
> > two things.
> > 
> > 1) Can you disable iLo2 and see if you can still reproduce the problem?
> 
> That will take a few days, I'll ask the on-site guys to check whether we
> have an external IP-KVM available. 
> 
> Would switching the uplink connection to eth1 (and not use eth0 in
> Linux) give some more clue as well?

Sure, let's try that.  Maybe this is the better way to go anyways.  I just
learned that disabling iLo2 doesn't necessarily disable the management
firmware on the network device.

For this to be a meaningful test though, we need to verify that the
driver sign-on messages have a line that reads "ASF[0]" on eth1.  Can
you confirm?

> > 2) Can you apply the following patch to get more information on when
> >    MMIO gets disabled?
> 
> Applied, I'll send you the information as soon as it happens again
> (which seems to be happening rather often the last couple of days).

Thanks.

