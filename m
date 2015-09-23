From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: Remove unneeded return from void function
Date: Wed, 23 Sep 2015 17:15:46 +0300
Message-ID: <5602B412.50506@cogentembedded.com>
References: <CAAOQCfQr9V-mb5uJdxk_=Npuy+Fx1ekAFoC2t-bWZJCqfLqmdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Guillaume Gomez <guillaume1.gomez@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAOQCfQr9V-mb5uJdxk_=Npuy+Fx1ekAFoC2t-bWZJCqfLqmdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/23/2015 1:31 PM, Guillaume Gomez wrote:

> Signed-off-by: Guillaume Gomez <guillaume1.gomez@gmail.com>
> ---
>   include/linux/netdevice.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 88a0069..4a444a1 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -457,7 +457,7 @@ void napi_complete_done(struct napi_struct *n, int
> work_done);

    The patch is line-wrapped.

>    */
>   static inline void napi_complete(struct napi_struct *n)
>   {
> -    return napi_complete_done(n, 0);
> +    napi_complete_done(n, 0);

    And tabs were converted to spaces.

MBR, Sergei
