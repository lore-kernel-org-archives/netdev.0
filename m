From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 0/2] sctp: Add GSO support
Date: Tue, 3 May 2016 13:47:45 -0300
Message-ID: <20160503164745.GE5676@localhost.localdomain>
References: <cover.1461965035.git.marcelo.leitner@gmail.com>
 <20160502.191614.608026435064266168.davem@davemloft.net>
 <20160503114918.GD5676@localhost.localdomain>
 <20160503.120915.2184693151751282220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, David.Laight@ACULAB.COM,
	alexander.duyck@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbcECQrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 12:47:49 -0400
Content-Disposition: inline
In-Reply-To: <20160503.120915.2184693151751282220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 12:09:15PM -0400, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Tue, 3 May 2016 08:49:18 -0300
> 
> > So this is just for pure tx path, no forwarding involved.
> 
> And if that GSO segment is looped back into the stack via the
> loopback interface, the packet classifier mirror action, or
> netfilter?
> 
> You cannot just GSO things and then not handle such packets
> properly on receive.

Good point. It will fail if one uses AUTH due to the reason I mentioned
for GRO. I have to split the GSO packet upon rx too and that should do
it. Will post a v2 when I have it.

Thanks,
Marcelo
