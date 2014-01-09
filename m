From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 09 Jan 2014 15:59:27 -0500 (EST)
Message-ID: <20140109.155927.205358101116161587.davem@davemloft.net>
References: <25B12960-1709-4E96-A278-9DBF9009C0F5@intel.com>
	<20140109.151957.1618381015670153898.davem@davemloft.net>
	<8566589F-17E2-47D4-AD38-1D42C6851642@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@cumulusnetworks.com, aaron.f.brown@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: mark.d.rustad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146AbaAIU7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:59:30 -0500
In-Reply-To: <8566589F-17E2-47D4-AD38-1D42C6851642@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Date: Thu, 9 Jan 2014 20:46:33 +0000

> I think I have found a way to address the barrier issue. I will add
> upper case macros that call the lower case inlines, so for a time
> both forms may exist, and then have a patch that will update the
> call sites, and then a patch to remove the macros.
> 
> Is that acceptable?

Yes.
