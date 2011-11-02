From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 - support for NLM_F_* flags at IPv6 routing
 requests
Date: Wed, 02 Nov 2011 03:28:16 -0400 (EDT)
Message-ID: <20111102.032816.595045810281014355.davem@davemloft.net>
References: <1320157347.11816.3.camel@lakki>
	<1320217791.12052.12.camel@lakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab1KBH2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 03:28:24 -0400
In-Reply-To: <1320217791.12052.12.camel@lakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Wed, 02 Nov 2011 09:09:51 +0200

> On Tue, 2011-11-01 at 16:27 +0200, Matti Vaittinen wrote:
>> Hi dee Ho again.
>> 
>> Here's the support for NLM_F_* flags at IPv6 routing requests once again.
>> 
>> This time if no NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
>> warning is printed, but no error is returned. Instead new route is added.
>> 
>> Exception is when NLM_F_REPLACE flag is given without NLM_F_CREATE, and
>> no matching route is found. In this case it should be safe to assume
>> that the request issuer is familiar with NLM_F_* flags, and does really
>> not want route to be created.
>> 
>> Specifying NLM_F_REPLACE flag will now make the kernel to search for
>> matching route, and replace it with new one. If no route is found and
>> NLM_F_CREATE is specified as well, then new route is created.
>> 
>> Also, specifying NLM_F_EXCL will yield returning of error if matching route 
>> is found.
>> 
>> Patch is created against linux-3.1-rc4
>> 
> 
> New patch where the definition of new error is removed as Stephen suggested.
> 
> Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

Please do not submit new versions of patches in this way by replying
and quoting your original commit log message.  That makes for lots
of work for me.

Instead, submit a fresh new full patch posting and prefix your subject
with something like "[PATCH v2]" to indicate it's a new version.
