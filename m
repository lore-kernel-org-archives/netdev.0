From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] ipv6: resend MLD report if a link-local address completes DAD
Date: Fri, 28 Jun 2013 15:51:43 +0200
Message-ID: <20130628135143.GE15799@order.stressinduktion.org>
References: <20130626220701.GA26180@order.stressinduktion.org> <20130627220448.GB25037@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:43523 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103Ab3F1Nvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 09:51:45 -0400
Content-Disposition: inline
In-Reply-To: <20130627220448.GB25037@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 07:04:48PM -0300, Flavio Leitner wrote:
> On Thu, Jun 27, 2013 at 12:07:01AM +0200, Hannes Frederic Sowa wrote:
> > RFC3590/RFC3810 specifies we should resend MLD reports as soon as a
> > valid link-local address is available.
> > 
> > We now use the valid_ll_addr_cnt to check if it is necessary to resend
> > a new report.
> > 
> > Changes since Flavio Leitner's version:
> > a) adapt for valid_ll_addr_cnt
> > b) resend first reports directly in the path and just arm the timer for
> >    mc_qrv-1 resends.
> > 
> > Reported-by: Flavio Leitner <fleitner@redhat.com>
> > Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> > Cc: David Stevens <dlstevens@us.ibm.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> > ---
> 
> Looks good as well and fixes the issue I had.
> (my signed-off is there already)

Thanks for the testing and review.

May I ask in what situation you want to increase the dad_transmits? Did they
get dropped as part of spanning tree initialization on a port?

Greetings,

  Hannes
