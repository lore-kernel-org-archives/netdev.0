From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] cosa.c : Array index 'i' is used before limits check.
Date: Tue, 24 Feb 2015 22:57:03 +0300
Message-ID: <54ECD78F.7040607@cogentembedded.com>
References: <1424807546-10013-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ameen Ali <ameenali023@gmail.com>, kas@fi.muni.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424807546-10013-1-git-send-email-ameenali023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/24/2015 10:52 PM, Ameen Ali wrote:

> avoid out-of-bounds-read by checking count before indexing.

> Signed-off-by: Ameen Ali <Ameenali023@gmail.com>
> ---
>   drivers/net/wan/cosa.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
> index 83c39e2..5252e21 100644
> --- a/drivers/net/wan/cosa.c
> +++ b/drivers/net/wan/cosa.c
> @@ -376,7 +376,7 @@ static int __init cosa_init(void)
>   	}
>   	for (i=0; i<MAX_CARDS; i++)
>   		cosa_cards[i].num = -1;
> -	for (i=0; io[i] != 0 && i < MAX_CARDS; i++)
> +	for (i=0; (i < MAX_CARDS) && (io[i] != 0) ; i++)

    Parens you've added aren't necessary.
    I suggest to add spaces after and before = in the first expression.

[...]

WBR, Sergei
