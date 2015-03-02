From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm: Clarify __GFP_NOFAIL deprecation status
Date: Mon, 2 Mar 2015 12:34:30 -0800 (PST)
Message-ID: <alpine.DEB.2.10.1503021233550.20808@chino.kir.corp.google.com>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz> <1425304483-7987-2-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Dave Chinner <david@fromorbit.com>,
	Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Michal Hocko <mhocko@suse.cz>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1425304483-7987-2-git-send-email-mhocko@suse.cz>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Mar 2015, Michal Hocko wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 51bd1e72a917..0cf9c2772988 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -57,8 +57,10 @@ struct vm_area_struct;
>   * _might_ fail.  This depends upon the particular VM implementation.
>   *
>   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> - * cannot handle allocation failures.  This modifier is deprecated and no new
> - * users should be added.
> + * cannot handle allocation failures. New users should be evaluated carefuly
> + * (and the flag should be used only when there is no reasonable failure policy)
> + * but it is definitely preferable to use the flag rather than opencode endless
> + * loop around allocator.
>   *
>   * __GFP_NORETRY: The VM implementation must not retry indefinitely.
>   *

s/carefuly/carefully/

Acked-by: David Rientjes <rientjes@google.com>
