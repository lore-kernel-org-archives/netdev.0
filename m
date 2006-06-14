From: David Miller <davem@davemloft.net>
Subject: Re: tcp_slow_start_after_idle
Date: Wed, 14 Jun 2006 16:06:43 -0700 (PDT)
Message-ID: <20060614.160643.93473808.davem@davemloft.net>
References: <20060613.223538.24611602.davem@davemloft.net>
	<44903D82.40007@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zach.brown@oracle.com, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63414
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964999AbWFNXGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 19:06:24 -0400
To: rick.jones2@hp.com
In-Reply-To: <44903D82.40007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 14 Jun 2006 09:46:58 -0700

> Also, does the congestion window "time out" or does it decay?

The modification made to the cwnd is indeed a decay function,
but the event is a time out, and it is also termed a restart
in other writings and contexts.

I think it's all the same. :)

> > +/* By default, RFC2861 behavior.  */
> > +int sysctl_tcp_slow_start_after_idle = 1;
> > +
> 
> Is this a candidate for "readmostly?"

All the networking sysctls are, we should do a sweep over them at some
point.

Thanks for reminding me.
