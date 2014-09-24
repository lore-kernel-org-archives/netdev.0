From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC repost 3/8] odp-util: formatting of datapath select
 group action
Date: Wed, 24 Sep 2014 13:55:44 +0900
Message-ID: <20140924045540.GA13314@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-4-git-send-email-simon.horman@netronome.com>
 <20140919134449.GA8257@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:57473 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaIXEz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 00:55:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so7868778pab.5
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 21:55:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140919134449.GA8257@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 02:44:49PM +0100, Thomas Graf wrote:
> On 09/18/14 at 10:55am, Simon Horman wrote:
> > Allow formatting of select group action. This is used
> > when pretty-printing datapath flows. Subsequent patches
> > will add support for the select group action to the datapath
> > and ovs-vswtichd.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  lib/odp-util.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 67 insertions(+)
> > 
> > diff --git a/lib/odp-util.c b/lib/odp-util.c
> > index 77b456f..4c8dd39 100644
> > --- a/lib/odp-util.c
> > +++ b/lib/odp-util.c
> > @@ -182,6 +182,71 @@ format_odp_sample_action(struct ds *ds, const struct nlattr *attr)
> >      ds_put_format(ds, "))");
> >  }
> >  
> > +static bool
> > +format_odp_bucket(struct ds *ds, const struct nlattr *attr)
> > +{
> > +    static const struct nl_policy ovs_sample_policy[] = {
> 
> Not that it would matter much but you might want to rename that to
> ovs_bucket_policy[]. Same below.

Thanks, I renamed all the new instances of ovs_sample_policy
(which I cut and pasted from the implementation of sample actions).
