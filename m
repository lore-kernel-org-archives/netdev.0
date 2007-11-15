From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Fri, 16 Nov 2007 00:53:25 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0711160039110.2986@u.domain.uli>
References: <200711131129.58868.borntraeger@de.ibm.com>
 <20071113.024500.155458534.davem@davemloft.net> <20071114021131.GB2523@verge.net.au>
 <Pine.LNX.4.58.0711150225280.3658@u.domain.uli> <20071115011431.GA8325@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, borntraeger@de.ibm.com,
	netdev@vger.kernel.org, ebiederm@xmission.com, wensong@linux-vs.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:4598 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751622AbXKOWxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 17:53:45 -0500
In-Reply-To: <20071115011431.GA8325@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 14 Nov 2007, Simon Horman wrote:

> > So, as long as these entries are not
> > accessible from sysctl it is safe to run without strategy handler but if
> > values can be changed then we will need strategy handler to
> > properly call update_defense_level() as done in proc_do_defense_mode()
> > as proc_handler. There could be side effects if new mode is not applied.
> 
> I'm not sure what you are getting at there. I did write a stratergy
> for update_defense_level(), but I didn't post it, as I thought that
> it would not be needed if CTL_UNNUMBERED is used.

	Thanks everyone! I now see that by using CTL_UNNUMBERED
for ctl_name stops any writes to 'data', so there is no need for
'strategy' handler.

Regards

--
Julian Anastasov <ja@ssi.bg>
