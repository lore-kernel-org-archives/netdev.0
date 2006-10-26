From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 13:57:36 -0700 (PDT)
Message-ID: <20061026.135736.111202572.davem@davemloft.net>
References: <20061025110843.0cbd18a7@freekitty>
	<4540F076.70801@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1210
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423663AbWJZU5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 16:57:35 -0400
To: jheffner@psc.edu
In-Reply-To: <4540F076.70801@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 26 Oct 2006 13:29:26 -0400

> My reservation in doing this would be that as an administrator, I may 
> want to choose exactly what congestion control is available any any 
> given time.  The different congestion control algorithms are not 
> necessarily fair to each other.
> 
> If the modules are autoloaded, I could still enforce this by moving the 
> modules out of /lib/modules, but I think it's cleaner to do it by 
> loading/unloading modules as appropriate.

Fair enough, and for the folks doing tests of congestion control
algorithms they can run as root or whatever.
