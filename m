From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] abysmal e1000 performance (DITR)
Date: Sat, 28 Aug 2004 18:58:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41310E0E.1060909@pobox.com>
References: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>	 <1093542930.1027.124.camel@jzny.localdomain>	 <1093550644.20769.130.camel@tubarao>  <412E478A.2000806@pobox.com> <1093555737.20769.135.camel@tubarao>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: tharbaugh@lnxi.com
In-Reply-To: <1093555737.20769.135.camel@tubarao>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thayne Harbaugh wrote:
> --- drivers/net/e1000/e1000_param.c.broken_ditr 2004-08-26 15:40:34.436456736 -0600
> +++ drivers/net/e1000/e1000_param.c     2004-08-26 15:49:07.186506880 -0600
> @@ -212,7 +212,7 @@
>  #define MAX_TXABSDELAY            0xFFFF
>  #define MIN_TXABSDELAY                 0
>   
> -#define DEFAULT_ITR                    1
> +#define DEFAULT_ITR                 8000
>  #define MAX_ITR                   100000
>  #define MIN_ITR                      100

applied
