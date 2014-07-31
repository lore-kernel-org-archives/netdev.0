From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: use kobject_put instead of _del
 after kobject_add
Date: Thu, 31 Jul 2014 11:16:28 -0700 (PDT)
Message-ID: <20140731.111628.1288677880511822667.davem@davemloft.net>
References: <1406633263-2115-1-git-send-email-vfalico@gmail.com>
	<20140730.173743.1842150455499005693.davem@davemloft.net>
	<20140731104601.GA4373@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbaGaSQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 14:16:30 -0400
In-Reply-To: <20140731104601.GA4373@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 31 Jul 2014 12:46:01 +0200

> On Wed, Jul 30, 2014 at 05:37:43PM -0700, David Miller wrote:
>>From: Veaceslav Falico <vfalico@gmail.com>
>>Date: Tue, 29 Jul 2014 13:27:43 +0200
>>
>>> Otherwise the name of the kobject isn't getting freed and other stuff
>>> from
>>> kobject_cleanup() isn't getting called. kobject_put() will call
>>> kobject_del() on its own in kobject_cleanup().
>>>
>>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>> CC: Andy Gospodarek <andy@greyhouse.net>
>>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>>
>>Introduced in v3.14, so maybe steer this to 'net' instead?
> 
> Good idea. Should I re-send it or can you just apply it to net?

I'll just apply it, thanks.
