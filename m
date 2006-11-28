From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] [IPVS] use msleep_interruptable() instead of ssleep()
 aka msleep()
Date: Tue, 28 Nov 2006 10:35:01 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0611281031190.2787@u.domain.uli>
References: <20061128062716.GA32377@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dean Manners <deanm@ispone.com.au>,
	Wensong Zhan <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:56335 "EHLO u.domain.uli")
	by vger.kernel.org with ESMTP id S935671AbWK1IeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 03:34:18 -0500
To: Horms <horms@verge.net.au>
In-Reply-To: <20061128062716.GA32377@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 28 Nov 2006, Horms wrote:

> Dean Manners notices that when an IPVS synchonisation daemons are
> started the system load slowly climbs up to 1. This seems to be related
> to the call to ssleep(1) (aka msleep(1000) in the main loop. Replacing
> this with a call to msleep_interruptable() seems to make the problem go
> away. Though I'm not sure that it is correct.

	The same is needed for sync_backup_loop

> -		ssleep(1);
> +		msleep_interruptible(1000);

Regards

--
Julian Anastasov <ja@ssi.bg>
