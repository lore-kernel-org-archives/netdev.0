From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ax25: Fix the build when sysctl support is
 disabled.
Date: Mon, 23 Apr 2012 22:15:52 -0400 (EDT)
Message-ID: <20120423.221552.1200047689249251213.davem@davemloft.net>
References: <4F95828A.8050403@xenotime.net>
	<m1obqirn5e.fsf_-_@fess.ebiederm.org>
	<4F9601CD.2070000@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	ralf@linux-mips.org
To: rdunlap@xenotime.net
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4F9601CD.2070000@xenotime.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 23 Apr 2012 18:28:45 -0700

> On 04/23/2012 05:25 PM, Eric W. Biederman wrote:
> 
>> 
>> Randy Dunlap <rdunlap@xenotime.net> reported:
>> 
>>> On 04/23/2012 12:07 AM, Stephen Rothwell wrote:
>>>
>>>> Hi all,
>>>>
>>>> Changes since 20120420:
>>>
>>>
>>> include/net/ax25.h:447:75: error: expected ';' before '}' token
>>>
>>> static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
>>> static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
>>>
>>> First function:  move ';' inside braces.
>>> Second function:  drop the ';'.
>> 
>> Put the semicolons where it makes sense.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> 
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks guys.
