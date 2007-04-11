From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [irda-users] [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Wed, 11 Apr 2007 12:02:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0704111158530.534@pcgl.dsa-ac.de>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
 <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de> <20070407005926.GE4177@sortiz.org>
 <20070410181037.GA3780@sortiz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mackerras <paulus@samba.org>,
	irda-users@lists.sourceforge.net, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:56397 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956AbXDKKCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 06:02:44 -0400
In-Reply-To: <20070410181037.GA3780@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007, Samuel Ortiz wrote:

> The patch below schedules irnet_flow_indication() asynchronously. Could
> you please give it a try (it builds, but I couldn't test it...) ? :

I'm afraid, your patch makes it worse - with my patch to ppp_generic it 
worked 5 hours before Ir stopped, remaining at 4mbaud, and only discovery 
timer was expiring periodically without actually doing anything; with your 
patch the same happens in about 5 minutes.

I'll double-verify it, and then will try the same work-queue approach, but 
from ppp_generic, rather than from irttp, combining our 2 patches.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
