From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] wireless-dev: relax sysfs permissions
Date: Tue, 22 Aug 2006 15:20:02 -0700
Message-ID: <20060822222002.GA29875@suse.de>
References: <1155736186.3600.29.camel@ux156> <20060822164740.51861395@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:22226 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751327AbWHVWU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 18:20:28 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060822164740.51861395@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 04:47:40PM +0200, Jiri Benc wrote:
> On Wed, 16 Aug 2006 15:49:45 +0200, Johannes Berg wrote:
> > The sysfs attributes add_iface and remove_iface both check for
> > CAP_NET_ADMIN whenever something is written. Hence, permissions for the
> > files should be relaxed so that someone who is not root but happens to
> > have CAP_NET_ADMIN can do things.
> 
> I'm not sure about this. Greg, what's the policy here?

I don't know, it's not a normal sysfs thing to rely on capability
checks, almost everything that I know of uses the permission bits on the
files.  But I don't have a problem with making the permissions on the
file open, yet restricting things to CAP_NET_ADMIN, if that preserves
the proper functionality.

thanks,

greg k-h
