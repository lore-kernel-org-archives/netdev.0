From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 17:34:17 -0700 (PDT)
Message-ID: <20080611.173417.189781943.davem@davemloft.net>
References: <20080610.224023.116817726.davem@davemloft.net>
	<20080611093645.GB4171@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbYFLAeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 20:34:17 -0400
In-Reply-To: <20080611093645.GB4171@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Jun 2008 09:36:45 +0000

> On 11-06-2008 07:40, David Miller wrote:
> ...
> > ehea_main: Does flush_scheduled_work() in ->stop method, converted to
> > 	   cancel_work_sync().
> 
> Looks like this work could be rearmed afterwards from
> ehea_qp_aff_irq_handler() (and maybe a few other places).

Good catch, but this bug exists both before and after
my changes :-)

It is certainly something which should be reported to
the EHEA developers.  Could you please do this?
