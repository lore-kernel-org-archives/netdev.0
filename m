From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -next] e100: fix printk format warning
Date: Wed, 18 Jun 2008 16:24:27 -0700
Message-ID: <9929d2390806181624g2749a7cex9b1d687c3db0d050@mail.gmail.com>
References: <20080618140741.79e21737.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>,
	jesse.brandeburg@intel.com, akpm <akpm@linux-foundation.org>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:45503 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbYFRXYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 19:24:30 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4873962rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 16:24:27 -0700 (PDT)
In-Reply-To: <20080618140741.79e21737.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 2:07 PM, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Fix printk format warning:
>
> drivers/net/e100.c:1145: warning: format '%d' expects type 'int', but argument 5 has type 'size_t'
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/e100.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- linux-next-20080618.orig/drivers/net/e100.c
> +++ linux-next-20080618/drivers/net/e100.c
> @@ -1142,7 +1142,7 @@ static const struct firmware *e100_reque
>        /* Firmware should be precisely UCODE_SIZE (words) plus three bytes
>           indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
>        if (fw->size != UCODE_SIZE * 4 + 3) {
> -               DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %d\n",
> +               DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %zu\n",
>                        fw_name, fw->size);
>                release_firmware(fw);
>                return ERR_PTR(-EINVAL);
>

Ack.
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
