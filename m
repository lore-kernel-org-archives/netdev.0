From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009,
 always first choosen
Date: Mon, 16 Apr 2007 07:30:33 +0200
Message-ID: <462309F9.6050005@trash.net>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org> <20070413144702.8ebf1cfe.akpm@linux-foundation.org> <462305C1.9030007@trash.net> <20070416052535.M41456@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: wijata@nec-labs.com, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64452 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbXDPFcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:32:35 -0400
In-Reply-To: <20070416052535.M41456@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Sorry, i will put my IMHO, since i am using it too.
> 
> I guess it can be useful for load-balancing scenario.


That makes sense with using multiple IPs (and we support doing that),
but whats the point of load-balancing to differenet *ports*?

> Is there way to provide both ways?
> Thinking... 60% done, But maybe this can be done over -m statistic already


2.6.21-rc supports randomized port selection (with iptables userspace
from SVN). Using the statistic match would work as well.
