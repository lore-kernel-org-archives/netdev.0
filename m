From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/7] drivers: isdn: act2000: capi.c: fix checkpatch errors
Date: Sat, 07 Feb 2015 22:09:36 +0300
Message-ID: <54D662F0.7060206@cogentembedded.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com> <1423335929-24926-3-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-3-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2015 10:05 PM, Bas Peters wrote:

> This patch fixes the following checkpatch errors:
> 	1. trailing statement
> 	1. assignment of variable in if condition
> 	1. incorrectly placed brace after function definition

> Signed-off-by: Bas Peters <baspeters93@gmail.com>
> ---
>   drivers/isdn/act2000/capi.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)

> diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
> index 3f66ca2..5d677e6 100644
> --- a/drivers/isdn/act2000/capi.c
> +++ b/drivers/isdn/act2000/capi.c
> @@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
>   			m->hdr.cmd.cmd = c;			\
>   			m->hdr.cmd.subcmd = s;			\
>   			m->hdr.msgnum = actcapi_nextsmsg(card); \
> -		} else m = NULL;				\
> +		} else

    Backslash is still missing here.

> +			m = NULL;				\
>   	}
>
>   #define ACTCAPI_CHKSKB if (!skb) {					\
[...]

WBR, Sergei
