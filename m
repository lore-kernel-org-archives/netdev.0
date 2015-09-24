From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 17/19] tools: bpf_jit_disasm: make get_last_jit_image
 return unsigned
Date: Thu, 24 Sep 2015 20:53:22 +0200
Message-ID: <560446A2.2020907@iogearbox.net>
References: <1443103227-25612-1-git-send-email-a.hajda@samsung.com> <1443103227-25612-18-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrzej Hajda <a.hajda@samsung.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443103227-25612-18-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2015 04:00 PM, Andrzej Hajda wrote:
> The function returns always non-negative values.
>
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
>
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
>
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> ---
> Hi,
>
> To avoid problems with too many mail recipients I have sent whole
> patchset only to LKML. Anyway patches have no dependencies.
>
> Regards
> Andrzej
> ---
>   tools/net/bpf_jit_disasm.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
> index 2cd3d4c..b422dbe 100644
> --- a/tools/net/bpf_jit_disasm.c
> +++ b/tools/net/bpf_jit_disasm.c
> @@ -156,7 +156,7 @@ static void put_log_buff(char *buff)
>   	free(buff);
>   }
>
> -static int get_last_jit_image(char *haystack, size_t hlen,
> +static unsigned int get_last_jit_image(char *haystack, size_t hlen,
>   			      uint8_t *image, size_t ilen)

I have no problem if you want to change this, but then please also
fix up the 2nd line's indentation to match the '(' as it was before.

Thanks !

>   {
>   	char *ptr, *pptr, *tmp;
>
