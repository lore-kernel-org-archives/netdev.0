From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 proposal
Date: Wed, 6 Aug 2008 13:04:45 +0300
Message-ID: <200808061304.45392.denys@visp.net.lb>
References: <200808060125.38260.denys@visp.net.lb> <489960B3.4050708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:60934 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbYHFKH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:07:29 -0400
In-Reply-To: <489960B3.4050708@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, Patrick McHardy wrote:
> It breaks batches that add links and then configure them. You need
> to invalidate the link map on "ip link add/del" and "ip tunnel add/del".
Probably for tc batch it doesn't matter, so this optimization can be done only 
for tc (i exclude also monitor functions, they must renew list of 
interfaces).

Is new patch looks better? (i test it, it compiles and doesn't break tc, and 
makes still things much faster on systems with many interfaces).





