From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] bonding: start slaves with link down for ARP monitor
Date: Sat, 14 Apr 2012 21:25:54 +0200
Message-ID: <20120414192554.GB8424@lion.mk-sys.cz>
References: <94e5ccf29d92f9a4b815f895b6bb8d9f326566cb.1334256203.git.mkubecek@suse.cz>
 <20120414015319.11e196d4@asterix.rh>
 <9048.1334380877@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kubecekserver.ph.gin.cz ([212.71.128.105]:39965 "EHLO
	kubecekserver.ph.gin.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab2DNT0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:26:05 -0400
Content-Disposition: inline
In-Reply-To: <9048.1334380877@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 13, 2012 at 10:21:17PM -0700, Jay Vosburgh wrote:
>
>       The functional part I'm not sure about yet is if the this will
> cause slave devices with fast autoneg to wait for an ARP monitor cycle
> before going link up according to ARP monitor.
>
>       I think this may work better if the initial slave state is set
> to whatever netif_carrier_ok() says, instead of unconditionally up or
> down.

This would mean the initial state would be always up for drivers not
supporting netif_carrier_ok(). But as far as I can see, only a few such
drivers are left and they are not very frequent ones. So I agree it will
be less harm to keep starting with up link state for these drivers than
to introduce an unnecessary delay for cards/driver which are fast enough.

I'll send updated version of the patch after I test it.

                                                          Michal Kubecek
