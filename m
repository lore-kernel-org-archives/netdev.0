From: "ravinandan arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Submission #4  for S2io 10GbE driver
Date: Mon, 22 Mar 2004 11:36:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003b01c41044$f3b06220$7410100a@S2IOtech.com>
References: <405C1656.8080004@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>,
        <alicia.pena@s2io.com>, "'Huy Phan'" <peter.phan@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Leonid Grossman'" <leonid.grossman@s2io.com>
In-Reply-To: <405C1656.8080004@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
Thanks for the patch cleanup.
Can you pls send us the final copy of s2ioDriver.patch file that you
applied
to the 2.6 kernel ? 

Regards,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Saturday, March 20, 2004 2:01 AM
To: Leonid Grossman
Cc: netdev@oss.sgi.com; 'ravinandan arakali';
raghavendra.koushik@s2io.com
Subject: Re: Submission #4 for S2io 10GbE driver

Jeff Garzik wrote:
> ===== drivers/net/s2io.h 1.1 vs 1.2 =====
> --- 1.1/drivers/net/s2io.h	Sat Mar 20 04:38:16 2004
> +++ 1.2/drivers/net/s2io.h	Sat Mar 20 04:47:53 2004
> @@ -14,8 +14,8 @@
>  #define _S2IO_H
>  
>  #define TBD 0
> -#define BIT(loc)        (((u64)0x8000000000000000ULL) >> loc)
> -#define vBIT(val, loc, sz)  (((u64)val) << (64-loc-sz))
> +#define BIT(loc)		(1ULL << (loc))
> +#define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))

and here is a patch correcting an incorrect cleanup...
