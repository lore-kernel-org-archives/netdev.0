From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 14:17:49 -0700 (PDT)
Message-ID: <20061027.141749.41635827.davem@davemloft.net>
References: <20061027152157.GB4632@c3po.0xdef.net>
	<45422A31.7070806@osdl.org>
	<20061027103016.3e8514d7@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30663
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752458AbWJ0VRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 17:17:48 -0400
To: shemminger@osdl.org
In-Reply-To: <20061027103016.3e8514d7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 Oct 2006 10:30:16 -0700

> My proposed method restricting TCP choices to fair algorithms.
> This a net wide, not system wide issue, it should not be done
> by kernel policy choice (capability), but by a build choice.

I think this sucks even worse than the current situation.

How difficult is it to understand that an administrator might
like to be able to build in and experiment with some congestion
control algorithms, yet still be able to keep his normal users
from using them?
