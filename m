From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 11:36:10 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161133320.15629@qirst.com>
References: <OF8AB07938.3DA9C6DD-ON8825759A.00522BB7-8825759A.0053414D@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:46242 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980AbZDPPnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:43:24 -0400
In-Reply-To: <OF8AB07938.3DA9C6DD-ON8825759A.00522BB7-8825759A.0053414D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, David Stevens wrote:

> This isn't what I suggested-- you have the default backwards. It must
> default
> to current behavior, or it's pointless.

If it would default to the current behavior then it would be incompatible
with the behavior of other operating systems and the surprising behavior
of the Linux multicast stack would continue to exist. The unusual behavior
needs to be switched on if wanted for legacy or other reasons.

> The text you have with it is overstated, too. Of course applications using
> your model can still receive unexpected data-- it does not reserve the
> port or multicast address to just your sender or to multicast traffic
> alone.

The application will no longer receive traffic from multicast groups that
it did not subscribe to. Yes unicast can still result in unexpected
traffic.
