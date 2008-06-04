From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Running single tests via ethtool
Date: Wed, 4 Jun 2008 15:13:50 +0100
Message-ID: <20080604141349.GA11300@solarflare.com>
References: <20080530220819.GJ1743@solarflare.com> <48443207.5090009@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:45797 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757963AbYFDOOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 10:14:01 -0400
Content-Disposition: inline
In-Reply-To: <48443207.5090009@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
[...]
> Well it really becomes of question of whether or not you want to be 
> importing a huge test suite into a kernel driver.  The ethtool stuff was 
> not meant to cover exhaustive tests, just a way to run "it works" 
> self-checks and diagnostics.

We're not intending to expand the tests massively, though there are a few
that should be added.  We just want to pick which to run.  I'm not entirely
clear why the customer wants this, but I can imagine wanting to run a single
test repeatedly if some aspect of a board is suspected to be intermittently
faulty.  Since there is no firmware in our current controller, the
initialisation is fairly complex and we wouldn't want to duplicate it outside
the driver in a standalone diagnostic program.  Besides which, unloading a
driver and keeping it unloaded seems to be increasingly tricky.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
