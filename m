From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 15:22:15 -0400
Message-ID: <1154892135.11649.8.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:38294 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751683AbWHFTWc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 15:22:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9oCg-000330-Ct
	for netdev@vger.kernel.org; Sun, 06 Aug 2006 15:22:26 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1154867083.6269.35.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-08 at 08:24 -0400, jamal wrote:

> Will try it before end of day. 

Looks good performance-wise; almost as good as the version i had.
Certainly better than the original e1000 (of course i am talking about
the overload case ;->).

Interesting thing to note:
only 0.001% of the time and only on one CPU was the
 __e1000_maybe_stop_tx::netif_start_queue() ever hit.
I guess that is sufficient to convince someone of the possibility of a
race ;-> Note, these C3s are damn slow CPUs by todays standards so i am
suspecting that % will be higher with faster CPUs.

cheers,
jamal

