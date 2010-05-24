From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output
	slave selection
Date: Mon, 24 May 2010 11:31:08 -0400
Message-ID: <20100524153108.GJ7497@gospo.rdu.redhat.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com> <17897.1273608579@death.nxdomain.ibm.com> <20100512002725.GA2460@localhost.localdomain> <25238.1273693314@death.nxdomain.ibm.com> <20100512221408.GI7497@gospo.rdu.redhat.com> <20100513171504.GD21535@shamino.rdu.redhat.com> <20100517184508.GD17419@hmsreliant.think-freely.org> <17188.1274124341@death.nxdomain.ibm.com> <12958.1274145714@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753617Ab0EXPb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 11:31:27 -0400
Content-Disposition: inline
In-Reply-To: <12958.1274145714@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 17, 2010 at 06:21:54PM -0700, Jay Vosburgh wrote:
> Jay Vosburgh <fubar@us.ibm.com> wrote:
> [...]
> >	For your patch, I'm exploring the idea of not setting
> >IFF_SLAVE_INACTIVE on "inactive" slaves for an "all_slaves_active"
> >option (I think that's a more descriptive name than "keep_all") instead
> >of adding a new KEEP_ALL flag bit to priv_flags.  Did you consider this
> >methodology and exclude it for some reason?
> 
> 	Following up to myself, I coded up approximately what I was
> talking about.  This doesn't require the extra priv_flag, and the sysfs
> _store is a little more complicated, but this appears to work (testing
> with ping -f after clearing the switch's MAC table to induce traffic
> flooding).  I didn't change the option name from "keep_all" here, but as
> far as the functionality goes, this seems to do what I think you want it
> to.
> 
> 	-J

This looks good to me, Jay.  I tested the patch here along with the
patch that started this thread and it works as expected.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

It seems like you were willing to take the patch that started this
thread rather than a change that adds a new mode.  If we agree that this
is the correct direction, can you take a look at the patch and decide if
you are willing to ACK it as-is or if more changes are needed?

Thanks,

-andy

