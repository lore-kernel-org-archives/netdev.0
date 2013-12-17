From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: RTM_DELROUTE on interface going down - when to send?
Date: Tue, 17 Dec 2013 15:01:02 +0100
Message-ID: <20131217140101.GB11216@unicorn.suse.cz>
References: <20131217110512.GA11216@unicorn.suse.cz>
 <CAKfDRXi86Tb6ocJ9kegfQqWDcXG8i20yxdK0UqSnQ=1WWaaOuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56368 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752536Ab3LQOBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 09:01:03 -0500
Content-Disposition: inline
In-Reply-To: <CAKfDRXi86Tb6ocJ9kegfQqWDcXG8i20yxdK0UqSnQ=1WWaaOuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 01:11:32PM +0100, Kristian Evensen wrote:
> On Tue, Dec 17, 2013 at 12:05 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
> >
> > Before I start with the patch, I would like to ask: would it be more
> > appropriate to send the message when the route is marked as dead or when
> > it is actually deleted from the trie?
> 
> I noticed the same thing a few months ago and submitted a patch
> (http://www.spinics.net/lists/netdev/msg254106.html). However, it was
> not applied because it would cause too much traffic on large-scale
> routers (see davem's reply here
> http://www.spinics.net/lists/netdev/msg254186.html).

Thank you for the pointer. However, I agree that the inconsistencies
(IPv4 vs. IPv6, RTM_DELROUTE vs. RTM_NEWROUTE) are really unfortunate.

                                                       Michal Kubecek
