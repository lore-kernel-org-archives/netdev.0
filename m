From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Update documentation for better built-in help
 with params
Date: Fri, 22 Jan 2010 18:32:23 -0800 (PST)
Message-ID: <20100122.183223.197255353.davem@davemloft.net>
References: <201001221901.o0MJ1oLk016090@wind.enjellic.com>
	<4B5A0991.9080701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@enjellic.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628Ab0AWCcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 21:32:12 -0500
In-Reply-To: <4B5A0991.9080701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 22 Jan 2010 15:24:49 -0500

> Update IPv6 documentation to describe how to set parameters when it's
> built-into the kernel.  Reported by <greg@enjellic.com>.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

So are you going to also add a mention of this fact to every single
place in the documentation that talks about some arbitrary module
option?

That doesn't make any sense, and neither does this patch.

It's better to make it more apparent that module options can
be set on the kernel command line when something is compiled
statically into the kernel.

That way it only needs to be explained in one place, not in
several.

I'm not applying this.
