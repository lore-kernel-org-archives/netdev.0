From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] add netpoll support for 802.1q vlans
Date: Thu, 8 Dec 2011 10:35:58 -0500
Message-ID: <20111208153558.GE30652@kvack.org>
References: <20111207010424.GA16496@kvack.org> <20111208.000730.63159506168958262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:40550 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab1LHPf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 10:35:59 -0500
Content-Disposition: inline
In-Reply-To: <20111208.000730.63159506168958262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2011 at 12:07:30AM -0500, David Miller wrote:
> From: Benjamin LaHaise <bcrl@kvack.org>
> Date: Tue, 6 Dec 2011 20:04:24 -0500
> 
> > Add netpoll support to 802.1q vlan devices.  Based on the netpoll support 
> > in the bridging code.  Tested on a forced_eth device with netconsole.
> > 
> > Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> 
> Bridging doesn't try to invoke a downstream netpoll operation at all,
> and neither should you.

Please have a look at net/bridge/br_device.c:br_netpoll_setup() which is 
where the approach came from.

Getting netconsole over vlans working is a requirement for those of us 
with machines plugged into ethernet switches that can't mix tagged and 
untagged packets on their ethernet ports.  I bumped into this while 
trying to capture a kernel crash on such a machine which doesn't have any 
external serial ports to use either.

> Also, please format your subject line correctly so I don't have to edit
> it when applying your patch.  You need to add an appropriate, lowercase,
> subsystem prefix after the [PATCH] tag otherwise people scanning the
> shortlog in GIT can't figure out what area your patch is in.
> 
> In this situation "vlan: " might be appropriate.

Sorry about that oversight, I'll try to remember for the future.

		-ben
-- 
"Thought is the essence of where you are now."
