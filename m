From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Wed, 28 May 2008 22:11:18 -0700
Message-ID: <20080528221118.63da4092.akpm@linux-foundation.org>
References: <482DA5B6.1020606@sngx.net>
	<482DB46A.8020103@cosmosbay.com>
	<482EF192.4070707@sngx.net>
	<482F5113.5090703@cosmosbay.com>
	<482F610D.2080108@sngx.net>
	<20080518003104.GK28241@solarflare.com>
	<482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59384 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbYE2FQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 01:16:21 -0400
In-Reply-To: <483E0AAE.2020107@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 May 2008 20:45:18 -0500 James Cammarata <jimi@sngx.net> wrote:

> I had originally submitted this ability as a patch to procfs, and
> general consensus was that it seemed "hackish" to do it that way.  It
> was suggested that it be implemented as a feature of ethtool, so I 
> thought I'd take on the challenge and add it that way.
> 
> I've laid the groundwork here, and added the ability to two of the 
> drivers for which I have hardware to test on (e1000 and pcnet32).  I 
> also added the code required to call this functionality to the ethtool 
> code base, and have been using that to test my changes (using -z as the 
> flag to ethtool for clearing stats for now).
> 
> If this is an acceptable start, I will gladly start working on adding 
> this to as many drivers as possible (we do have some bnx2 hardware, 
> though I'm not sure if it's available for testing).
> 
> Some other sys-admins have mentioned to me that ethtool doesn't work 
> sometimes and they fall back to using mii-tool to configure interfaces,
> so I'd still like to have the procfs change implemented to accommodate 
> that hardware, but I agree, this is a better way forward.

You didn't provide a reason from adding this feature to the kernel.

Many of the kernel's accounting accumulators cannot be reset.  We
handle that in userspace tools by using subtraction.
