From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 11:49:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021140320.30182@router.home>
References: <alpine.DEB.2.00.1006021025200.30182@router.home>  <1275492754.2725.192.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021103410.30182@router.home>  <20100602.091909.113727983.davem@davemloft.net>  <alpine.DEB.2.00.1006021126500.30182@router.home>
 <1275496439.2725.203.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:39535 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932786Ab0FBQtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:49:21 -0400
In-Reply-To: <1275496439.2725.203.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> take a look at
>
> http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/html/SystemTap_Beginners_Guide/useful-systemtap-scripts.html#dropwatch

System tap? Oh no. Also skbs may be freed for legitimate reasons. The
point is that the loss detection needs to be usable for a regular mortal.
With the counters in /proc/net/snmp you have something that is easy to
handle.

The approach with systemtap will need lots of work to both get the tracing
environment setup (local competence in systemtap) and participation by a
developer to figure out what the output means. Then there is also the
additional code overhead that you do not want by default in the kernel. So
we would need a different kernel for diagnostics.
