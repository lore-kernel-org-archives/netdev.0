From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 13:43:26 -0500 (EST)
Message-ID: <20121130.134326.730429492162984746.davem@davemloft.net>
References: <50B8E4E6.2040901@xenotime.net>
	<50B8ECB3.2090801@schaufler-ca.com>
	<50B8EF79.4080907@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, paul@paul-moore.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <50B8EF79.4080907@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 30 Nov 2012 09:40:09 -0800

> On 11/30/2012 09:28 AM, Casey Schaufler wrote:
> 
>> Because NETLABEL depends on INET SECURITY_SMACK
>> has to explicitly call out the dependency.
>> 
>> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
> 
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>
> 
> Thanks for the quick fix.

In what tree does this Kconfig file look like this?

In my net-next tree the current dependencies are expressed as:

	depends on NETLABEL && SECURITY_NETWORK
