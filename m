From: David Miller <davem@davemloft.net>
Subject: Re: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti
 overflow
Date: Tue, 17 Jun 2008 21:54:02 -0700 (PDT)
Message-ID: <20080617.215402.169100957.davem@davemloft.net>
References: <48568125.4090500@cn.fujitsu.com>
	<4857B542.6030703@trash.net>
	<48586A04.6040800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759411AbYFREyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:54:02 -0400
In-Reply-To: <48586A04.6040800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 18 Jun 2008 09:51:00 +0800

> Patrick McHardy said the following on 2008-6-17 20:59:
> >> +            printk(KERN_ERR "%s: promiscuity touches roof, "
> >> +                "set promiscuity failed, promiscuity feature "
> >> +                "of device will be broken.\n", dev->name);
> >> +            return -EOVERFLOW;
> >> +        }
> >> +    }
> > 
> > Assuming the caller does proper error handling, that printk is
> > not true.
> > 
> 
> Yes.
> But currently, no caller handling this, and I think even if I make
> some callers to handle this, but there maybe some callers and their
> callers do not want to handle error condition.
> So I need a KERN_WARNING here.
> If some day, all of the caller handle the error properly, we can
> remove this printk.
> 
> Here is v3:

Patrick, ACK?
