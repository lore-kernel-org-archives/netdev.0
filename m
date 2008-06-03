From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: non-root, non-real network manipulation for netconf testing
Date: Tue, 3 Jun 2008 11:05:14 +0100
Message-ID: <20080603100513.GA18161@solarflare.com>
References: <20080603080529.GA9010@lapse.madduck.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev discussion list <netdev@vger.kernel.org>,
	netconf developers list <netconf-devel@lists.alioth.debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:42911 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752143AbYFCKF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 06:05:29 -0400
Content-Disposition: inline
In-Reply-To: <20080603080529.GA9010@lapse.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

martin f krafft wrote:
> Dear networking wizards,
> 
> This is a bit of a self-reflexive mail, but I hope some of you might
> have some input...
> 
> In writing netconf[0], we are having a bit of a problem with the
> test suite, since many of netconf's operations require root rights
> (e.g. interface manipulation with /bin/ip). In addition, a test
> suite manipulating the network configuration of the running machine
> is not really something I feel comfortable with.
> 
> 0. http://netconf.alioth.debian.org
> 
> So I am trying to come up with alternative plans, of which there are
> three:
> 
> 1. do not fail tests that need root rights when run as non-root
> 2. set up a VDE network (which still requires root rights)
> 3. write a mock /bin/ip which pretends to be doing what it'd be doing
[...]

Have you considering running the tests in User-Mode Linux or some
other kind of virtualised environment?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
