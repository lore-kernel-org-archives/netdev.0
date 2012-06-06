From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 20:35:50 +0000 (UTC)
Message-ID: <jqoev6$l2b$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <20120606.115130.1091814494251887552.davem@davemloft.net>
 <jqo9ej$ao4$1@dough.gmane.org>
 <20120606.131703.870120997635192180.davem@davemloft.net>
 <jqoe90$fs3$2@dough.gmane.org> <1339014685.26966.73.camel@edumazet-glaptop>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:51665 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756772Ab2FFUgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 16:36:15 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScMxf-0007Ac-5S
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 22:36:11 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:36:11 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:36:11 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2012-06-06 at 20:24 +0000, Grant Edwards wrote:
>
>> Is skb_tailroom() guaranteed to be >= the requested size?
>> 
>
> Of course, but only right after alloc_skb().

That's good enough.
     
-- 
Grant Edwards               grant.b.edwards        Yow! Okay ... I'm going
                                  at               home to write the "I HATE
                              gmail.com            RUBIK's CUBE HANDBOOK FOR
                                                   DEAD CAT LOVERS" ...
