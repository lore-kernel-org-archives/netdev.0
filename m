From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier handling
Date: Wed, 6 Aug 2014 01:00:59 +0100
Message-ID: <20140806000059.GA7315@zion.uk.xensource.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
 <20140805.160748.1185917042908283028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <zoltan.kiss@citrix.com>, <wei.liu2@citrix.com>,
	<Ian.Campbell@citrix.com>, <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140805.160748.1185917042908283028.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 05, 2014 at 04:07:48PM -0700, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Mon, 4 Aug 2014 16:20:56 +0100
> 
> > This series starts using carrier off as a way to purge packets when the guest is
> > not able (or willing) to receive them. It is a much faster way to get rid of
> > packets waiting for an overwhelmed guest.
> > The first patch changes current netback code where it relies currently on
> > netif_carrier_ok.
> > The second turns off the carrier if the guest times out on a queue, and only
> > turn it on again if that queue (or queues) resurrects.
> > 
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> Applied, but I have some reservations:
> 

Wow, this is fast. I appreciate your speed, but there's still
outstanding issues in the series.

Apart from some comments on maintainability, the biggest problem is that
there's a bug in second patch that needs to be fixed; or I need to be
proved wrong.  We need to set aside some more time to get those
questions answered. I don't think this series is suitable to go in as
is.

DaveM, could you please advise how to deal with this situation?

Wei.
