From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2] bridge: Fix return values of
	br_multicast_add_group/br_multicast_new_group
Date: Fri, 10 Dec 2010 23:52:27 +0100
Message-ID: <20101210225226.GL10190@distanz.ch>
References: <20101209082924.6d797871@nehalam> <1291903356-30618-1-git-send-email-tklauser@distanz.ch> <1291987084-27302-1-git-send-email-tklauser@distanz.ch> <20101210.130125.233714141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:55422 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab0LJWw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 17:52:28 -0500
Content-Disposition: inline
In-Reply-To: <20101210.130125.233714141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-10 at 22:01:25 +0100, David Miller <davem@davemloft.net> wrote:
> From: Tobias Klauser <tklauser@distanz.ch>
> Date: Fri, 10 Dec 2010 14:18:04 +0100
> 
> > If br_multicast_new_group returns NULL, we would return 0 (no error) to
> > the caller of br_multicast_add_group, which is not what we want. Instead
> > br_multicast_new_group should return ERR_PTR(-ENOMEM) in this case.
> > Also propagate the error number returned by br_mdb_rehash properly.
> > 
> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> 
> Looks good, applied to net-next-2.6
> 
> Please in the future make is clear, in your subject line, which
> tree this patch is meant for.
> 
> I had to figure it out by trial and error, because this patch
> does not apply properly to net-2.6

Sorry about that. I'll do so in the future.

Thanks
