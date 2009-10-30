From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 21:38:16 -0700 (PDT)
Message-ID: <20091029.213816.35637194.davem@davemloft.net>
References: <20091030035128.GA3380@jenkins.home.ifup.org>
	<20091029.211219.182331672.davem@davemloft.net>
	<20091030043050.GB3380@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752208AbZJ3Ehw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:37:52 -0400
In-Reply-To: <20091030043050.GB3380@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <bphilips@suse.de>
Date: Thu, 29 Oct 2009 21:30:50 -0700

> The buglet is that other drivers seem to report "Link detected: no"
> after probe while sky2 doesn't.

I agree that we should report something consistent before interface
up and 'no' is probably the best.

I remember fixing something similar in other drivers a few months
ago.
