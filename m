From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH][next] sctp: make array sctp_sched_ops static
Date: Wed, 11 Oct 2017 18:24:51 -0300
Message-ID: <20171011212451.GA4454@localhost.localdomain>
References: <20171011101757.18825-1-colin.king@canonical.com>
 <1507718690.3552.50.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin King <colin.king@canonical.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507718690.3552.50.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 11, 2017 at 03:44:50AM -0700, Joe Perches wrote:
> On Wed, 2017-10-11 at 11:17 +0100, Colin King wrote:
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > The array sctp_sched_ops  is local to the source and
> > does not need to be in global scope, so make it static.
> > 
> > Cleans up sparse warning:
> > symbol 'sctp_sched_ops' was not declared. Should it be static?
> > 
> > Signed-off-by: Colin Ian King <colin.king@canonical.com>
> > ---
> >  net/sctp/stream_sched.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/sctp/stream_sched.c b/net/sctp/stream_sched.c
> > index 03513a9fa110..0b83ec51e43b 100644
> > --- a/net/sctp/stream_sched.c
> > +++ b/net/sctp/stream_sched.c
> > @@ -124,7 +124,7 @@ static struct sctp_sched_ops sctp_sched_fcfs = {
> >  extern struct sctp_sched_ops sctp_sched_prio;
> >  extern struct sctp_sched_ops sctp_sched_rr;
> >  
> > -struct sctp_sched_ops *sctp_sched_ops[] = {
> > +static struct sctp_sched_ops *sctp_sched_ops[] = {
> >  	&sctp_sched_fcfs,
> >  	&sctp_sched_prio,
> >  	&sctp_sched_rr,
> 
> Perhaps these should also be const to move more data to text

Yes. There are no plans on supporting any sort of dynamic updates on
this, at least for now.

  Marcelo
