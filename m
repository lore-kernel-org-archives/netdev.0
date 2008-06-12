From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 06:29:26 +0000
Message-ID: <20080612062926.GB4005@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net> <20080611093645.GB4171@ff.dom.local> <20080611.173417.189781943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org, Jan-Bernd Themann <ossthema@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:55074 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbYFLGZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 02:25:19 -0400
Received: by ug-out-1314.google.com with SMTP id h2so267596ugf.16
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 23:25:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080611.173417.189781943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2008 at 05:34:17PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 11 Jun 2008 09:36:45 +0000
> 
> > On 11-06-2008 07:40, David Miller wrote:
> > ...
> > > ehea_main: Does flush_scheduled_work() in ->stop method, converted to
> > > 	   cancel_work_sync().
> > 
> > Looks like this work could be rearmed afterwards from
> > ehea_qp_aff_irq_handler() (and maybe a few other places).
> 
> Good catch, but this bug exists both before and after
> my changes :-)
> 
> It is certainly something which should be reported to
> the EHEA developers.  Could you please do this?

I hope this RE & CC will suffice.

Regards,
Jarek P.
