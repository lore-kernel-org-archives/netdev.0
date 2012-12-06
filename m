From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: build failure of latest ethtool
Date: Thu, 6 Dec 2012 16:29:36 +0000
Message-ID: <1354811376.2828.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <50C0C276.5060809@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59117 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422879Ab2LFQ3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 11:29:44 -0500
In-Reply-To: <50C0C276.5060809@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 18:06 +0200, Or Gerlitz wrote:
> Hi Ben,
> 
> FYI, building the latest ethtool git fails since sfpid.c is not present 
> in the Makefile.
[...]

If you want to build from git you have to run:

./autogen.sh && ./configure && make

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
