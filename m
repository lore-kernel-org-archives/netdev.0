From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH mac80211-next] nl80211: Allow set network namespace by fd
Date: Mon, 19 Jan 2015 16:34:57 +0200
Message-ID: <20150119143457.GA6988@angus-think.wlc.globallogic.com>
References: <1421073245-20312-1-git-send-email-vadim4j@gmail.com>
 <1421225246.1950.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:54334 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbASOpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:45:35 -0500
Content-Disposition: inline
In-Reply-To: <1421225246.1950.22.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 09:47:26AM +0100, Johannes Berg wrote:
> On Mon, 2015-01-12 at 16:34 +0200, Vadim Kochan wrote:
> 
> > --- a/net/core/net_namespace.c
> > +++ b/net/core/net_namespace.c
> > @@ -361,6 +361,7 @@ struct net *get_net_ns_by_fd(int fd)
> >  	return ERR_PTR(-EINVAL);
> >  }
> >  #endif
> > +EXPORT_SYMBOL_GPL(get_net_ns_by_fd);
> 
> Does this seem OK? Vadim is adding support for using the ns-by-fd in
> nl80211, which can be a module as part of cfg80211.
> 
> johannes
> 
PING ... in case if this email was missed ...

Thanks,
