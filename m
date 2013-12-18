From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 3/4] tcp: metrics: Delete all entries matching a certain
 destination
Date: Wed, 18 Dec 2013 10:58:53 +0100
Message-ID: <20131218095853.GA5181@cpaasch-mac>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
 <1387109444-1104-4-git-send-email-christoph.paasch@uclouvain.be>
 <20131217.145751.53681780657108721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39805 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRJ7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:59:07 -0500
Content-Disposition: inline
In-Reply-To: <20131217.145751.53681780657108721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/12/13 - 14:57:51, David Miller wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Sun, 15 Dec 2013 13:10:43 +0100
> 
> > As we now can have multiple entries per destination-IP, the "ip
> > tcp_metrics delete address ADDRESS" command should delete all of them.
> > 
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> 
> You have to adjust how you're doing patches #3 and #4.
> 
> Create the new attribute for the source address first, then
> allow the source address to be specified in the deletion
> command.
> 
> Make the source address optional in delete commands, to be
> compatible with existing tools, and have it mean "ANY".

Thanks for the feedback, David.
I will resubmit when I have the time to do the changes.


Christoph
