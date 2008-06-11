From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 09:36:45 +0000
Message-ID: <20080611093645.GB4171@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:48838 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbYFKJcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 05:32:39 -0400
Received: by gv-out-0910.google.com with SMTP id e6so690474gvc.37
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 02:32:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-2008 07:40, David Miller wrote:
...
> ehea_main: Does flush_scheduled_work() in ->stop method, converted to
> 	   cancel_work_sync().

Looks like this work could be rearmed afterwards from
ehea_qp_aff_irq_handler() (and maybe a few other places).

Jarek P.
