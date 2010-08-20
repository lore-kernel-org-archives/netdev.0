From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 1/2] s2io: remove lro parameter
Date: Fri, 20 Aug 2010 16:54:04 +0800
Message-ID: <4C6E42AC.4070401@redhat.com>
References: <20100818075530.5926.67960.sendpatchset@localhost.localdomain> <20100818153626.GC9202@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234Ab0HTIts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 04:49:48 -0400
In-Reply-To: <20100818153626.GC9202@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/10 23:36, Jon Mason wrote:
> On Wed, Aug 18, 2010 at 12:51:09AM -0700, Amerigo Wang wrote:
>>
>> As suggested by David, this parameter can die, we can use ethtool
>> to turn LRO on/off. Compile tests only.
>
> Needs some additional removal
>
> Line 41 and 42 " * lro: Specifies whether to enable Large Receive ..."
> As you have removed the modparm
>
> Line 8286 "if (sp->lro)"
> As it will always be on in this instance
>
>
> Also, all references to "sp->lro" can be converted to "(dev->features
> &  NETIF_F_LRO)", removing an unnecessary variable.
>

Thanks for pointing these out.
I will fix them later.

-- 
The opposite of love is not hate, it's indifference.
  - Elie Wiesel
