From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: fix ICMP secure_redirects
Date: Mon, 7 Nov 2011 17:05:17 -0200
Message-ID: <20111107170517.6acb1f87@asterix.rh>
References: <1320680505-26367-1-git-send-email-fbl@redhat.com>
	<20111107.133541.808346933690781560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834Ab1KGTNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 14:13:20 -0500
In-Reply-To: <20111107.133541.808346933690781560.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Nov 2011 13:35:41 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Mon,  7 Nov 2011 13:41:45 -0200
> 
> > It should accept ICMP redirects from any host and not
> > just from gateways when secure_redirects is disabled.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> This is changing the default behavior, and could break things for
> people.
> 
> We have sort-of discussed this already, and agreed that the tests
> made in this code before my inetpeer reworking had to be reinstated
> exactly as it was.

Right, so I cannot change either values 0 or 1 then. For some
reason I thought I couldn't change only the default behavior.
I will think on something else then.
thanks,
fbl
