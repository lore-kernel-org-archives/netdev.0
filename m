From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: Kill references to UTS_RELEASE
Date: Tue, 25 Jan 2011 14:39:25 -0500
Message-ID: <1295984365.11300.4.camel@lap75545.ornl.gov>
References: <20110124.151214.28803162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute2.ornl.gov ([160.91.86.17]:33460 "EHLO emroute2.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255Ab1AYUAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 15:00:12 -0500
Received: from emroute2.ornl.gov ([127.0.0.1])
 by emroute2.ornl.gov (PMDF V6.5-x5 #31823)
 with ESMTP id <0LFL00KMXFXSW9@emroute2.ornl.gov> for netdev@vger.kernel.org;
 Tue, 25 Jan 2011 14:39:28 -0500 (EST)
In-reply-to: <20110124.151214.28803162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-24 at 15:12 -0800, David Miller wrote:
> This makes the driver get rebuilt every single time you
> type 'make' which is beyond rediculious.

Indeed, that's stupid.

> I hereby declare this driver to have version "1.0"

Wish you'd gone to 1.6 or 2.0 since the last version before Joe's/my
changes was 1.5.9, but it's pretty irrelevant anyways. Hmm, does
anything complain if we just remove the MODULE_VERSION?


