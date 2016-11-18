From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/7] net: cpsw: fix leaks and probe deferral
Date: Fri, 18 Nov 2016 13:49:15 -0500 (EST)
Message-ID: <20161118.134915.1991221192285505942.davem@davemloft.net>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Thu, 17 Nov 2016 17:39:57 +0100

> This series fixes as number of leaks and issues in the cpsw probe-error
> and driver-unbind paths, some which specifically prevented deferred
> probing.
 ...
> v2
>  - Keep platform device runtime-resumed throughout probe instead of
>    resuming in the probe error path as suggested by Grygorii (patch
>    1/7).
> 
>  - Runtime-resume platform device before registering any children in
>    order to make sure it is synchronously suspended after deregistering
>    children in the error path (patch 3/7).

Series applied, thanks.
