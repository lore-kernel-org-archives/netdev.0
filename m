From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 6/6] rtnetlink: remove IFLA_SLAVES definition
Date: Thu, 23 Jan 2014 14:43:47 -0800 (PST)
Message-ID: <20140123.144347.115158262468644462.davem@davemloft.net>
References: <1390387435-23918-1-git-send-email-jiri@resnulli.us>
	<20140123.124716.330893227222440804.davem@davemloft.net>
	<20140123213345.GA2764@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbaAWWns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:43:48 -0500
In-Reply-To: <20140123213345.GA2764@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Jan 2014 22:33:45 +0100

> Thu, Jan 23, 2014 at 09:47:16PM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Wed, 22 Jan 2014 11:43:55 +0100
>>
>>Secondly, you can't remove this, otherwise the next IFLA_* value added
>>here will reuse that old number potentially breaking userland apps.
> 
> This has been in net-next tree for 3 days. It was a mistake, I think
> there is very legit to remove this now, isn't it?

Fair enough, please resend with fixed Subj.
