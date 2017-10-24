From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] wimax/i2400m: Remove VLAIS
Date: Tue, 24 Oct 2017 12:46:59 -0700
Message-ID: <20171024194659.GC96615@google.com>
References: <20171009194153.30467-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Behan Webster <behanw@converseincode.com>,
        Mark Charlebois <charlebm@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Guenter Roeck <groeck@chromium.org>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009194153.30467-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Mon, Oct 09, 2017 at 12:41:53PM -0700 Matthias Kaehlcke ha dit:

> From: Behan Webster <behanw@converseincode.com>
> 
> Convert Variable Length Array in Struct (VLAIS) to valid C by converting
> local struct definition to use a flexible array. The structure is only
> used to define a cast of a buffer so the size of the struct is not used
> to allocate storage.
> 
> Signed-off-by: Behan Webster <behanw@converseincode.com>
> Signed-off-by: Mark Charebois <charlebm@gmail.com>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  drivers/net/wimax/i2400m/fw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
> index c9c711dcd0e6..a89b5685e68b 100644
> --- a/drivers/net/wimax/i2400m/fw.c
> +++ b/drivers/net/wimax/i2400m/fw.c
> @@ -652,7 +652,7 @@ static int i2400m_download_chunk(struct i2400m *i2400m, const void *chunk,
>  	struct device *dev = i2400m_dev(i2400m);
>  	struct {
>  		struct i2400m_bootrom_header cmd;
> -		u8 cmd_payload[chunk_len];
> +		u8 cmd_payload[];
>  	} __packed *buf;
>  	struct i2400m_bootrom_header ack;

ping

any comments on this?
