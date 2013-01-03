From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: update master carrier state
Date: Thu, 03 Jan 2013 02:15:35 -0800 (PST)
Message-ID: <20130103.021535.1980763300980291186.davem@davemloft.net>
References: <20121230214723.GD1575@minipsycho.orion>
	<20121230220616.GA2065@obelix.rh>
	<20121230221052.GF1575@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073Ab3ACKPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 05:15:36 -0500
In-Reply-To: <20121230221052.GF1575@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 30 Dec 2012 23:10:52 +0100

> Sun, Dec 30, 2012 at 11:06:16PM CET, fbl@redhat.com wrote:
>>On Sun, Dec 30, 2012 at 10:47:23PM +0100, Jiri Pirko wrote:
>>> Sun, Dec 30, 2012 at 07:27:29PM CET, fbl@redhat.com wrote:
>>> >Update master's carrier state when there is any
>>> >change with its ports.
>>> 
>>> 
>>> This patch looks good to me. Just one nitpick I spotted....
>>> 
>>> >+	bool team_linkup;
>>> >+
>>> >+	team_linkup = false;
>>> 
>>> 
>>> This can be squashed together.
>>
>>Ok, but that increases the static size of the module because it
>>moves the variable out of bss.
>>
>>I have no strong opinion on either case, so it's up to you.
> 
> Ok :)
> 
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Applied.
