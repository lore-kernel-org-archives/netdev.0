From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
	resetting -> dead NIC
Date: Thu, 19 Mar 2009 19:06:44 +0100
Message-ID: <20090319180644.GA30702@lxbsc01>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:55237 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964AbZCSSGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:06:50 -0400
Content-Disposition: inline
In-Reply-To: <20090319165842.GA10819@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 09:58:42AM -0700, Matt Carlson wrote:

Hello Matt,

> Hi Bernhard.  I talked to Michael about this and we'd like you to try
> two things.
> 
> 1) Can you disable iLo2 and see if you can still reproduce the problem?

That will take a few days, I'll ask the on-site guys to check whether we
have an external IP-KVM available. 

Would switching the uplink connection to eth1 (and not use eth0 in
Linux) give some more clue as well?

> 2) Can you apply the following patch to get more information on when
>    MMIO gets disabled?

Applied, I'll send you the information as soon as it happens again
(which seems to be happening rather often the last couple of days).

Bernhard
