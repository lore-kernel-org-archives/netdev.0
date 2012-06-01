From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: call netif_napi_del at errpaths and at driver
 unload
Date: Fri, 01 Jun 2012 14:25:31 -0400 (EDT)
Message-ID: <20120601.142531.544977894901194434.davem@davemloft.net>
References: <1338465080-22720-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338465080-22720-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Thu, 31 May 2012 17:21:20 +0530

> when register_netdev fails, the init'ed NAPIs by netif_napi_add must be
> deleted with netif_napi_del, and also when driver unloads, it should
> delete the NAPI before unregistering netdevice using unregister_netdev.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Francois, I'm assuming you will merge this to me after you've
done some testing.
