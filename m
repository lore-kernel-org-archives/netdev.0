From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Sun, 28 Aug 2011 02:09:05 -0400 (EDT)
Message-ID: <20110828.020905.835790029923646089.davem@davemloft.net>
References: <4E5664B5.6000806@genband.com>
	<4E56942A.3080905@monom.org>
	<CA+RrjuXe8kcU+rWT5v88x3u_CMwsdnEAFj7mjDU22p57HCeHhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wagi@monom.org, chris.friesen@genband.com, xemul@parallels.com,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	containers@lists.osdl.org
To: matt.helsley@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab1H1GJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 02:09:21 -0400
In-Reply-To: <CA+RrjuXe8kcU+rWT5v88x3u_CMwsdnEAFj7mjDU22p57HCeHhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Helsley <matt.helsley@gmail.com>
Date: Sat, 27 Aug 2011 16:39:11 -0700

> LD_PRELOAD is widely regarded as a debugging and tracing method -- it's not
> usually suitable for implementing features. Why? Because there's nothing
> stopping an application from resetting LD_PRELOAD and re-exec'ing to escape
> the measurements and limitations such a preload implements. Plus naive use
> of LD_PRELOAD could easily interfere with other things that use it. For
> example what if you want to use DMTCP with this?

LD_PRELOAD is also terrible as a "normal" facility because it breaks
prelinking.
