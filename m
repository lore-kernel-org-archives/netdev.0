From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: unresponsive vlan on top of bond with fail_over_mac=active
Date: Wed, 17 Oct 2012 13:08:52 +0200
Message-ID: <20121017110852.GA14967@unicorn.suse.cz>
References: <20121010231122.GB28935@unicorn.suse.cz>
 <8588.1349926471@death.nxdomain>
 <20121011103757.GA13873@unicorn.suse.cz>
 <29107.1350002028@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41209 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab2JQLIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 07:08:55 -0400
Content-Disposition: inline
In-Reply-To: <29107.1350002028@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 11, 2012 at 05:33:48PM -0700, Jay Vosburgh wrote:
>=20
> 	Have you tried the "follow" setting to fail_over_mac?

Yes, it works both for me and for the customer. They actually tried it
themselves before reporting the bug. I explained that "follow" is more
suitable also for other reasons and I hope they will accept it.

> 	What kernel are you looking at?  In current mainline, bonding
> does have bond_set_multicast_list as ndo_set_rx_mode, although it
> doesn't propagate unicast address information, only multicast.  I
> believe this has been the case for a long time.

I'm sorry, you are right. What I was looking at was actually 3.0 where
=2Endo_set_multicast_list is used rather than .ndo_set_rx_mode (changed=
 by
commit afc4b13d in v3.2-rc1).

Thank you for your help,
                                                        Michal Kube=E8e=
k
