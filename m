From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 6/6] rtnetlink: remove IFLA_SLAVES definition
Date: Thu, 23 Jan 2014 22:33:45 +0100
Message-ID: <20140123213345.GA2764@minipsycho.orion>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
 <1390387435-23918-1-git-send-email-jiri@resnulli.us>
 <20140123.124716.330893227222440804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:45390 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbaAWVdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:33:50 -0500
Received: by mail-ea0-f177.google.com with SMTP id n15so639108ead.8
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 13:33:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140123.124716.330893227222440804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 23, 2014 at 09:47:16PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 22 Jan 2014 11:43:55 +0100
>
>> Not used anymore, and never should be.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>First of all your Subject doesn't match the patch, the subject mentions
>IFLA_SLAVES whereas the patch deletes IFLA_BOND_SLAVE.

Yep, sorry, IFLA_SLAVE was the original name, which I removed. Should I
repost?

>
>Secondly, you can't remove this, otherwise the next IFLA_* value added
>here will reuse that old number potentially breaking userland apps.

This has been in net-next tree for 3 days. It was a mistake, I think
there is very legit to remove this now, isn't it?

>
>I'm not applying this, sorry.
