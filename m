From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] xilinx: Fix compiler warning
Date: Sun, 22 Jun 2014 15:15:17 +0400
Message-ID: <53A6BAC5.80206@cogentembedded.com>
References: <1403432461-18296-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?TWFudWVsIFNjaMO2bGxpbmc=?= <manuel.schoelling@gmx.de>,
	michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403432461-18296-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/22/2014 02:21 PM, Manuel Sch=C3=B6lling wrote:

> The time comparsion functions require arguments of type unsigned long
> instead of (signed) long.

> Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>

[...]

> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index 60c4196..2d069a3 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -351,7 +351,6 @@ static void __init get_fs_names(char *page)
>   				continue;
>   			line++;
>
> -			/* append fsname */
>   			memmove(fsnames, line, strlen(line)+1);
>   			fsnames +=3D strlen(fsnames)+1;
>   		} while (page !=3D NULL);
>

   Seems like unrelated random change.

WBR, Sergei
