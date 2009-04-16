From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 15:19:49 -0700 (PDT)
Message-ID: <20090416.151949.134404096.davem@davemloft.net>
References: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
	<alpine.DEB.1.10.0904161659440.7855@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753610AbZDPWUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:20:03 -0400
In-Reply-To: <alpine.DEB.1.10.0904161659440.7855@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 17:04:30 -0400 (EDT)

> Can you give us a list of products that verifiably rely on the current
> behavior?

Christoph just drop this, we're not creating a system-wide default
selection that backs away from 15+ years of precedence.

Maybe Solaris has so few users that it's OK for them to go down
that path, but for us it's unacceptable to do things like this.

Fix your application.  And as David noted, it will be not only
more robust, but also still work on those "other systems."

So even your "works on all systems" argument is groundless.  If
you make it work under Linux it will in fact work on all systems,
and be more robust in the case of other applications using the
same multicast address and port.
