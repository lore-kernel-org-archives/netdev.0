From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Can we rely on ethernet header padding?
Date: Wed, 20 Mar 2013 10:54:26 +0100
Message-ID: <20130320095426.GA20373@unicorn.suse.cz>
References: <20130319150545.GA18218@unicorn.suse.cz>
 <1363706495.2558.14.camel@edumazet-glaptop>
 <20130319154806.GB18218@unicorn.suse.cz>
 <20130319142553.3e08e7b9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53239 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758216Ab3CTJy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 05:54:27 -0400
Content-Disposition: inline
In-Reply-To: <20130319142553.3e08e7b9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 02:25:53PM -0700, Stephen Hemminger wrote:
> 
> My view is that the bridge code must check before assuming headroom.
> But because of that, it means a packet copy would be necessary for cases
> where packets arrive without enough headroom.

Yes, but for most users this is better than a crash. How about issuing a
WARN_ONCE() in such case so that we avoid writing out of the buffer but
still allow developers (and users who check logs) to catch the problem?

                                                          Michal Kubecek
