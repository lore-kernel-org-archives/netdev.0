From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] trace: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 08:20:02 -0400
Message-ID: <1371730802.18733.73.camel@gandalf.local.home>
References: <51C2E265.9010209@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fweisbec@gmail.com, mingo@redhat.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Zhao Hongjiang <zhaohongjiang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C2E265.9010209@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix is to a networking tracepoint. It should go through the
networking folks.

-- Steve


On Thu, 2013-06-20 at 19:07 +0800, Zhao Hongjiang wrote:
> for NUL terminated string, need alway set '\0' in the end.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
> ---
>  include/trace/events/sock.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
> index 779abb9..333d8b5 100644
> --- a/include/trace/events/sock.h
> +++ b/include/trace/events/sock.h
> @@ -44,7 +44,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
>  	),
>  
>  	TP_fast_assign(
> -		strncpy(__entry->name, prot->name, 32);
> +		strlcpy(__entry->name, prot->name, 32);
>  		__entry->sysctl_mem = prot->sysctl_mem;
>  		__entry->allocated = allocated;
>  		__entry->sysctl_rmem = prot->sysctl_rmem[0];
