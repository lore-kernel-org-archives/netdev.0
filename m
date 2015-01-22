From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH mac80211-next] nl80211: Allow set network namespace by fd
Date: Thu, 22 Jan 2015 12:50:42 +0100
Message-ID: <1421927442.1894.2.camel@sipsolutions.net>
References: <1421073245-20312-1-git-send-email-vadim4j@gmail.com>
	 <1421225246.1950.22.camel@sipsolutions.net>
	 <20150119143457.GA6988@angus-think.wlc.globallogic.com>
	 <20150122113259.GA20706@angus-think.local>
	 (sfid-20150122_124403_278920_529DCA35)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56643 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbbAVLur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 06:50:47 -0500
In-Reply-To: <20150122113259.GA20706@angus-think.local> (sfid-20150122_124403_278920_529DCA35)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 13:32 +0200, Vadim Kochan wrote:
> On Mon, Jan 19, 2015 at 04:34:57PM +0200, Vadim Kochan wrote:
> > On Wed, Jan 14, 2015 at 09:47:26AM +0100, Johannes Berg wrote:
> > > On Mon, 2015-01-12 at 16:34 +0200, Vadim Kochan wrote:
> > > 
> > > > --- a/net/core/net_namespace.c
> > > > +++ b/net/core/net_namespace.c
> > > > @@ -361,6 +361,7 @@ struct net *get_net_ns_by_fd(int fd)
> > > >  	return ERR_PTR(-EINVAL);
> > > >  }
> > > >  #endif
> > > > +EXPORT_SYMBOL_GPL(get_net_ns_by_fd);
> > > 
> > > Does this seem OK? Vadim is adding support for using the ns-by-fd in
> > > nl80211, which can be a module as part of cfg80211.
> > > 
> > > johannes
> > > 
> > PING ... in case if this email was missed ...
> > 
> > Thanks,
> 
> Hi Johannes,
> 
> Does it mean that patch will be rejected in case if no one answer on
> this ?:)

Nah, I'll eventually take it :)

johannes
