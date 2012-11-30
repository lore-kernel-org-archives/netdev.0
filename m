From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 10:47:23 -0800
Message-ID: <50B8FF3B.80003@schaufler-ca.com>
References: <50B8E4E6.2040901@xenotime.net> <50B8ECB3.2090801@schaufler-ca.com> <50B8EF79.4080907@xenotime.net> <20121130.134326.730429492162984746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, paul@paul-moore.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121130.134326.730429492162984746.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2012 10:43 AM, David Miller wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
> Date: Fri, 30 Nov 2012 09:40:09 -0800
>
>> On 11/30/2012 09:28 AM, Casey Schaufler wrote:
>>
>>> Because NETLABEL depends on INET SECURITY_SMACK
>>> has to explicitly call out the dependency.
>>>
>>> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
>>
>> Acked-by: Randy Dunlap <rdunlap@xenotime.net>
>>
>> Thanks for the quick fix.
> In what tree does this Kconfig file look like this?

James Morris' security-next

>
> In my net-next tree the current dependencies are expressed as:
>
> 	depends on NETLABEL && SECURITY_NETWORK
>
