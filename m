From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH 0/2] net: pktgen: fix race between pktgen_thread_worker()
 and kthread_stop()
Date: Fri, 10 Jul 2015 08:32:47 -0300
Message-ID: <20150710113247.GI1841@localhost.localdomain>
References: <20150708194154.GA26534@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jan Stancek <jstancek@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbbGJLcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 07:32:50 -0400
Content-Disposition: inline
In-Reply-To: <20150708194154.GA26534@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 09:41:54PM +0200, Oleg Nesterov wrote:
> Hello,
> 
> I am not familiar with this code and I have no idea how to test
> these changes, so 2/2 comes as a separate change. 1/2 looks like
> the obvious bugfix, and probably candidate for -stable.
> 
> Oleg.
> 
>  net/core/pktgen.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
> 

Both patches tested here, works for me.

Thanks,
Marcelo
