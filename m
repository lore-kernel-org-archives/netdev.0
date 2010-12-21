From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bnx2x: remove bogus check
Date: Tue, 21 Dec 2010 10:51:48 -0800 (PST)
Message-ID: <20101221.105148.71131041.davem@davemloft.net>
References: <20101221070401.GF1936@bicker>
	<1292939316.21210.7084.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752482Ab0LUSvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 13:51:19 -0500
In-Reply-To: <1292939316.21210.7084.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 21 Dec 2010 15:48:36 +0200

> On Mon, 2010-12-20 at 23:04 -0800, Dan Carpenter wrote:
>> We dereferenced params on the line before so it's too late to check if
>> params is NULL.  In fact, params can never be NULL and strict_cos is
>> either 0 or 1 so that part of the check is bogus too.  Let's remove it.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Thanks Dan!
> 
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks everyone.
