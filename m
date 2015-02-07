From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch errors
Date: Sat, 07 Feb 2015 20:51:59 +0300
Message-ID: <54D650BF.5000400@cogentembedded.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com> <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/07/2015 08:06 PM, Bas Peters wrote:

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
> +			m = NULL;				\

    Documentation/CodingStyle has an extra rule for such case: *else* branch 
should also have {} since *if* branch has {}.

[...]

WNR, Sergei
