From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Fri, 18 Dec 2009 17:20:54 +0000
Message-ID: <20091218172054.556de51b@lxorguk.ukuu.org.uk>
References: <20091218154634.79decdc4@lxorguk.ukuu.org.uk>
	<20091218163348.GA24269@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-14?B?QW3pcmljbw==?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:37861 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751873AbZLRRUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:20:35 -0500
In-Reply-To: <20091218163348.GA24269@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> the LSM-based version *does not* resolve the situation to my satisfaction as a
> userland hacker due to the well-known and long-standing adoption and
> compositionality problems facing small LSMs. ;)

For things like Fedora it's probably an "interesting idea, perhaps we
should do it using SELinux" sort of problem, but a config option for a
magic network prctl is also going to be hard to adopt without producing a
good use case - and avoiding that by dumping crap into everyones kernel
fast paths isn't a good idea either.

