From: jamal <hadi@cyberus.ca>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 14:21:03 -0400
Message-ID: <1148494863.5325.28.camel@jzny2>
References: <20060523.182217.59656237.davem@davemloft.net>
	 <447412CA.50303@ipom.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:56981 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932412AbWEXSVF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 14:21:05 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fixyn-00029G-Pi
	for netdev@vger.kernel.org; Wed, 24 May 2006 14:21:09 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <447412CA.50303@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-24-05 at 01:01 -0700, Phil Dibowitz wrote:
[..]
> 
> For your reference, here's the two times I've posted it this month - I'm
> happy to send it along again.


The problem with resetting stats is it is _most definetely_ going to
break management apps like SNMP.

This is not to say this is not useful for testing and at times debugging
- but backward compat and not pissing off the standards whic count on
this long standing feature is more important. So if you can 
make it work without breaking apps, it will be more palatable i am sure
to both Dave and Jeff. I would go as far as suggest that you should
allow for arbitrary setting (of which 0 is a speacial case).

cheers,
jamal

