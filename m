From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v2 6/6] sctp: convert sctp_assoc_set_id to use
 idr_alloc_cyclic
Date: Sun, 31 Mar 2013 06:23:38 -0400
Message-ID: <20130331062338.6c80022a@tlielax.poochiereds.net>
References: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
	<1364412578-7462-7-git-send-email-jlayton@redhat.com>
	<20130328135308.GA14489@neilslaptop.think-freely.org>
	<20130328140406.GB14489@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	tj@kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab3CaKYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Mar 2013 06:24:04 -0400
In-Reply-To: <20130328140406.GB14489@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Mar 2013 10:04:06 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Thu, Mar 28, 2013 at 09:53:08AM -0400, Neil Horman wrote:
> > On Wed, Mar 27, 2013 at 03:29:38PM -0400, Jeff Layton wrote:
> > > (Note: compile-tested only)
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > > Cc: Sridhar Samudrala <sri@us.ibm.com>
> > > Cc: Neil Horman <nhorman@tuxdriver.com>
> > > Cc: "David S. Miller" <davem@davemloft.net>
> > > Cc: linux-sctp@vger.kernel.org
> > > Cc: netdev@vger.kernel.org
> > > ---
> > >  net/sctp/associola.c | 16 ++--------------
> > >  1 file changed, 2 insertions(+), 14 deletions(-)
> > > 
> > I don't see anything wrong with this patch per-se, but the idr_alloc_cyclic call
> > isn't integrated with net/net-next or Linus' tree yet.  If we don't gate this
> > patch on that integration, we'll break the build.
> > Neil
> > 
> Actually, I just noticed that you only sent us 6/6 here, I'm assuming a prior
> patch in the series adds the idr_alloc_cyclic code?  if so, I've seen the prior
> version


Yes, idr_alloc_cyclic is added in patch #1. v2 has some slight changes
from v1 but it's essentially the same concept.

> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>
