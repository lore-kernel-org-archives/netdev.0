From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 17:16:40 -0700
Message-ID: <1154650600.3117.36.camel@rh4>
References: <20060803235326.GC7894@thunk.org>
 <20060803.165654.45876296.davem@davemloft.net>
 <20060803235927.GB10932@gondor.apana.org.au>
 <20060803.170143.20633018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tytso@mit.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:47112 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932350AbWHDAPG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:15:06 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060803.170143.20633018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 17:01 -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 4 Aug 2006 09:59:27 +1000
> 
> > Watchdogs usually require one heartbeat every 30 seconds or so.  Does
> > the ASF heartbeat need to be that frequent?
> 
> The ASF heartbeat needs to be sent every 2 seconds.
> 

Yep, we send it every 2 seconds and it will reset in 5 seconds after the
last heartbeat.  So the margin is 3 seconds.  These numbers are somewhat
arbitrary and the goal is to allow ASF to function properly without too
much delay after the system has crashed.

