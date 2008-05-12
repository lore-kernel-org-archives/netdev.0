From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Sun, 11 May 2008 23:18:06 -0700 (PDT)
Message-ID: <20080511.231806.193710614.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com>
	<36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
	<4827D947.8090804@acm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, mchan@broadcom.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, john.ronciak@intel.com
To: liblit@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbYELGSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 02:18:13 -0400
In-Reply-To: <4827D947.8090804@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Liblit <liblit@acm.org>
Date: Mon, 12 May 2008 00:44:39 -0500

> Jesse Brandeburg wrote:
> > and for e1000e (which you should be using for 82566)
> 
> That seems unlikely.  When I replace "alias eth0 e1000" with "alias eth0 
> e100e" in my module configuration I lose the network interface entirely. 

You're missing a zero in that string, it's "e1000e" not "e100e", and
did you make sure to enable CONFIG_E1000E in your kernel config?

