From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 20:24:00 +0000 (UTC)
Message-ID: <jqoe90$fs3$2@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <20120606.115130.1091814494251887552.davem@davemloft.net>
 <jqo9ej$ao4$1@dough.gmane.org>
 <20120606.131703.870120997635192180.davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48650 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574Ab2FFUZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 16:25:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScMmu-0000Uh-1T
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 22:25:04 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:25:04 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:25:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, David Miller <davem@davemloft.net> wrote:
> From: Grant Edwards <grant.b.edwards@gmail.com>
> Date: Wed, 6 Jun 2012 19:01:40 +0000 (UTC)
>
>> That's what I'll do as soon as I can find a definition of what the API
>> for alloc_skb() actually _is_.  It has clearly changed in the past few
>> years.
>
> And it will continue to change.  There are no stable APIs inside of
> the kernel, none.

Oh, I know (as does anybody who has maintained a driver for more than
a few months).  Right now, I'm just trying to find out what the
current API for alloc_skb() is.

Is skb_tailroom() guaranteed to be >= the requested size?

-- 
Grant Edwards               grant.b.edwards        Yow! I'm wet!  I'm wild!
                                  at               
                              gmail.com            
