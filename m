From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net sysctl: Add place holder functions for when sysctl
 support is compiled out of the kernel.
Date: Mon, 23 Apr 2012 19:24:42 -0400 (EDT)
Message-ID: <20120423.192442.379812896211622385.davem@davemloft.net>
References: <4F958598.6080305@xenotime.net>
	<m1lilmt7v5.fsf_-_@fess.ebiederm.org>
	<4F95D9F5.3040407@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4F95D9F5.3040407@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 23 Apr 2012 15:38:45 -0700

> On 04/23/2012 03:13 PM, Eric W. Biederman wrote:
> 
>> 
>> Randy Dunlap <rdunlap@xenotime.net> reported:
>>> On 04/23/2012 12:07 AM, Stephen Rothwell wrote:
>>>
>>>> Hi all,
>>>>
>>>> Changes since 20120420:
>>>
>>>
>>>
>>> ERROR: "unregister_net_sysctl_table" [net/phonet/phonet.ko] undefined!
>>> ERROR: "register_net_sysctl" [net/phonet/phonet.ko] undefined!
>>>
>>> when CONFIG_SYSCTL is not enabled.
>> 
>> Add static inline stub functions to gracefully handle the case when sysctl
>> support is not present.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> 
> 
> Yep, that works.
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks everyone.
