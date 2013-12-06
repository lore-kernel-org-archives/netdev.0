From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/5] neigh: store parms type inside the structure
Date: Fri, 6 Dec 2013 21:13:29 +0100
Message-ID: <20131206201329.GA24971@minipsycho.orion>
References: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
 <1386354544-19122-4-git-send-email-jiri@resnulli.us>
 <20131206.150840.2078088427369267519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:38736 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758604Ab3LFUNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:13:34 -0500
Received: by mail-ee0-f51.google.com with SMTP id b15so500705eek.10
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 12:13:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131206.150840.2078088427369267519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 06, 2013 at 09:08:40PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri,  6 Dec 2013 19:29:02 +0100
>
>> There is going to be needed later on to distinguish parms instance
>> between ipv4 and ipv6. So just store the type inside.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Please just use neigh_parms->tbl->family.

I somehow missed that. Thanks. Will send v2.



>
>Thanks.
