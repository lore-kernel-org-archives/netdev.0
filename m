From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2 net-next] team: add ethtool support
Date: Thu, 3 Jan 2013 10:32:17 -0200
Message-ID: <20130103123217.GB2278@obelix.rh>
References: <1356835053-25602-1-git-send-email-fbl@redhat.com>
 <1356992186.31299.1.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3ACMcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 07:32:23 -0500
Content-Disposition: inline
In-Reply-To: <1356992186.31299.1.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2012 at 10:16:26PM +0000, Ben Hutchings wrote:
> On Sun, 2012-12-30 at 00:37 -0200, Flavio Leitner wrote:
> > This patch adds few ethtool operations to team driver.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> > ---
> > v2 - removed generic statistics from ethtool
> > 
> >  drivers/net/team/team.c | 17 +++++++++++++++++
> >  1 file changed, 17 insertions(+)
> > 
> > diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> > index ad86660..7665a088 100644
> > --- a/drivers/net/team/team.c
> > +++ b/drivers/net/team/team.c
> [...]
> > +static void team_ethtool_get_drvinfo(struct net_device *dev,
> > +				     struct ethtool_drvinfo *drvinfo)
> > +{
> > +	strncpy(drvinfo->driver, DRV_NAME, 32);
> > +	strncpy(drvinfo->version, UTS_RELEASE, 32);
> > +}
> [...]
> 
> These must be null-terminated, so use strlcpy() not strncpy().

Ok, I will post another patch fixing this and few other  drivers as
well.

Thank you!
-- 
fbl
