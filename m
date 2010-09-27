From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br2684: fix scheduling while atomic
Date: Sun, 26 Sep 2010 18:29:35 -0700 (PDT)
Message-ID: <20100926.182935.70187312.davem@davemloft.net>
References: <20100922144329.0cb3cf86@thirdoffive.cmf.nrl.navy.mil>
	<1285242654-9891-1-git-send-email-karl@hiramoto.org>
	<538742.564.qm@web58407.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karl@hiramoto.org, netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: mmvinni@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754544Ab0I0B3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:29:15 -0400
In-Reply-To: <538742.564.qm@web58407.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikko Vinni <mmvinni@yahoo.com>
Date: Thu, 23 Sep 2010 09:51:24 -0700 (PDT)

> From: Karl Hiramoto <karl@hiramoto.org>
>> Subject: [PATCH] br2684: fix scheduling while atomic
>> 
>> You can't call atomic_notifier_chain_unregister() while in atomic  context.
>> 
>> Fix, call un/register_atmdevice_notifier in module __init and  __exit.
>> 
>> Bug  report:
>> http://comments.gmane.org/gmane.linux.network/172603
>> 
>> Signed-off-by:  Karl Hiramoto <karl@hiramoto.org>
> 
> Feel free to add
> 
> Reported-and-tested-by: Mikko Vinni <mmvinni@yahoo.com>

Applied, thanks guys.
