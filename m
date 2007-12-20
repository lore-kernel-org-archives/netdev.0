From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC] net: napi fix
Date: Thu, 20 Dec 2007 10:52:17 +0100
Message-ID: <18282.15185.592112.550961@robur.slu.se>
References: <47601A73.5010804@myri.com>
	<20071212.093819.205755031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:50470 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888AbXLTJw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 04:52:26 -0500
In-Reply-To: <20071212.093819.205755031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:

 > > Is the netif_running() check even required?
 > 
 > No, it is not.
 > 
 > When a device is brought down, one of the first things
 > that happens is that we wait for all pending NAPI polls
 > to complete, then block any new polls from starting.

 Hello!

 Yes but the reason was not to wait for all pending polls to
 complete so a server/router could be rebooted even under high-
 load and DOS. We've experienced some nasty problems with this.

 Cheers.
					--ro
