From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC repost 5/8] datapath: Move last_action() helper to
 datapath.h
Date: Wed, 24 Sep 2014 15:00:16 +0900
Message-ID: <20140924060013.GB13314@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-6-git-send-email-simon.horman@netronome.com>
 <20140919140638.GC8257@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60378 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbaIXGA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 02:00:27 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so3792833pdb.0
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 23:00:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140919140638.GC8257@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 03:06:38PM +0100, Thomas Graf wrote:
> On 09/18/14 at 10:55am, Simon Horman wrote:
> > diff --git a/datapath/datapath.h b/datapath/datapath.h
> > index c5d3c86..74a15e6 100644
> > --- a/datapath/datapath.h
> > +++ b/datapath/datapath.h
> > @@ -209,4 +209,9 @@ do {								\
> >  	if (net_ratelimit())					\
> >  		pr_info("netlink: " fmt, ##__VA_ARGS__);	\
> >  } while (0)
> > +
> > +static inline bool last_action(const struct nlattr *a, int rem)
> > +{
> > +	return a->nla_len == rem;
> > +}
> >  #endif /* datapath.h */
> 
> Can we rename & move this to <net/netlink.h> instead?

Sure, how about nla_is_last()?
