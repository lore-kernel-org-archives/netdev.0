From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net ax25: Fix the build when sysctl support is disabled.
Date: Mon, 23 Apr 2012 18:28:45 -0700
Message-ID: <4F9601CD.2070000@xenotime.net>
References: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>	<4F95828A.8050403@xenotime.net> <m1obqirn5e.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1obqirn5e.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/2012 05:25 PM, Eric W. Biederman wrote:

> 
> Randy Dunlap <rdunlap@xenotime.net> reported:
> 
>> On 04/23/2012 12:07 AM, Stephen Rothwell wrote:
>>
>>> Hi all,
>>>
>>> Changes since 20120420:
>>
>>
>> include/net/ax25.h:447:75: error: expected ';' before '}' token
>>
>> static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
>> static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
>>
>> First function:  move ';' inside braces.
>> Second function:  drop the ';'.
> 
> Put the semicolons where it makes sense.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> ---
> 
> Resent to include David Miller.
> 
>  include/net/ax25.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ax25.h b/include/net/ax25.h
> index 8a7a122..5d23521 100644
> --- a/include/net/ax25.h
> +++ b/include/net/ax25.h
> @@ -444,8 +444,8 @@ extern void ax25_uid_free(void);
>  extern int ax25_register_dev_sysctl(ax25_dev *ax25_dev);
>  extern void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev);
>  #else
> -static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
> -static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
> +static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0; }
> +static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {}
>  #endif /* CONFIG_SYSCTL */
>  
>  #endif



-- 
~Randy
