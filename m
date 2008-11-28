From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH-mm 8/8] decnet: remove private wrappers of endian helpers
Date: Fri, 28 Nov 2008 02:32:21 +0100
Message-ID: <200811280232.21544.ioe-lkml@rameria.de>
References: <1227733974.5511.130.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"linux-netdev" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754343AbYK1Bai@vger.kernel.org>
In-Reply-To: <1227733974.5511.130.camel@brick>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Harvey,

On Wednesday 26 November 2008, Harvey Harrison wrote:
> diff --git a/include/net/dn.h b/include/net/dn.h
> index 6277783..7cd6bb8 100644
> --- a/include/net/dn.h
> +++ b/include/net/dn.h
> @@ -4,9 +4,7 @@
>  #include <linux/dn.h>
>  #include <net/sock.h>
>  #include <asm/byteorder.h>
> -
> -#define dn_ntohs(x) le16_to_cpu(x)
> -#define dn_htons(x) cpu_to_le16(x)
> +#include <asm/unalignedh>
^^^^^^^^^^^^^^^^^^^^^^^^^^^ How does this compile?

But I guess David fixed this up :-)

Best Regards

Ingo Oeser
