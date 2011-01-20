From: Jarek =?iso-8859-2?Q?Kami=F1ski?= <jarek@vilo.eu.org>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Thu, 20 Jan 2011 14:55:34 +0100
Message-ID: <20110120135534.GA24545@rocket.almost.secure.la>
References: <AANLkTikxpOS2fJ1Sqv=Lg6cX1TE+1W-ZxFV+YMOH1+Yp@mail.gmail.com>
 <1295493603.2906.107.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: Ben Hutchings <ben@decadent.org.uk>, 609538@bugs.debian.org,
	Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vilo.eu.org ([80.52.229.66]:36666 "EHLO vilo.eu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609Ab1ATOEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 09:04:23 -0500
Content-Disposition: inline
In-Reply-To: <1295493603.2906.107.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 20, 2011 at 03:20:03AM +0000, Ben Hutchings wrote:
> On Thu, 2011-01-20 at 10:04 +0700, Daniel J Blueman wrote:
>> I see that Francois' patch is present in 2.6.38-rc1; is there a way to
>> avoid this delay, or is this likely in request_firmware?

> It's a known problem with calls to request_firmware() when userland is
> not running (early initialisation or resume from sleep).  It may be
> fixable.

It was partially fixed in commit
f1e02ed109df5f99abf942b8ccc99960cb09dd38 in linux-2.6.git (r8169: keep
firmware in memory.). Sorry for not reporting it here, I clicked "reply"
instead of "group reply" late in the night.

If this commit could be included in Debian kernel, the bug could be
closed.

J.
