From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] fix ia64 build failure when CONFIG_SFC=m
Date: Tue, 29 Jul 2008 14:00:40 -0700 (PDT)
Message-ID: <20080729.140040.72089155.davem@davemloft.net>
References: <20080729013650.GH9663@sgi.com>
	<57C9024A16AD2D4C97DC78E552063EA3080BA318@orsmsx505.amr.corp.intel.com>
	<20080729174839.GG10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony.luck@intel.com, jgarzik@redhat.com,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	netdev@vger.kernel.org, matthew@wil.cx, holt@sgi.com,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752743AbYG2VAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 17:00:43 -0400
In-Reply-To: <20080729174839.GG10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Jul 2008 18:48:41 +0100

> I think a single core in each package can generally saturate the
> memory bus and this is why spreading the load wider is not useful.

I disagree, especially for routing and firewall setups.

You want as many cpu threads as possible, even on the same core,
doing the routing and firewall lookups through the various
datastructures, in parallel.
