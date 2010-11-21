From: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 60/62] rt2x00: Use static const
Date: Sun, 21 Nov 2010 09:58:55 +0100
Message-ID: <4CE8DF4F.5050803@gmail.com>
References: <cover.1290305773.git.joe@perches.com> <d8bfaded20da2265673391a81536d63b0e81dc7f.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d8bfaded20da2265673391a81536d63b0e81dc7f.1290305776.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/21/10 03:39, Joe Perches wrote:
> Using static const generally increases object text and decreases data size.
> It also generally decreases overall object size.
> 
>    text	   data	    bss	    dec	    hex	filename
>   40197	     56	   8336	  48589	   bdcd	drivers/net/wireless/rt2x00/rt2800lib.o.new
>   40205	     56	   8336	  48597	   bdd5	drivers/net/wireless/rt2x00/rt2800lib.o.old
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

For rt2x00 this is just a tiny optimization, but for what it's worth:

Acked-by: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  drivers/net/wireless/rt2x00/rt2800lib.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
> index ce8df66..7563161 100644
> --- a/drivers/net/wireless/rt2x00/rt2800lib.c
> +++ b/drivers/net/wireless/rt2x00/rt2800lib.c
> @@ -2166,7 +2166,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
>  					 SHARED_KEY_MODE_ENTRY(i), 0);
>  
>  	for (i = 0; i < 256; i++) {
> -		u32 wcid[2] = { 0xffffffff, 0x00ffffff };
> +		static const u32 wcid[2] = { 0xffffffff, 0x00ffffff };
>  		rt2800_register_multiwrite(rt2x00dev, MAC_WCID_ENTRY(i),
>  					      wcid, sizeof(wcid));
>  

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
