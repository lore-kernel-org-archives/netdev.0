From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [PATCH] IPVS' Kconfig LBLC and LBLCR configuration typo
Date: Mon, 14 Jul 2003 22:16:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F130F84.8010104@drugphish.ch>
References: <20030714140350.GB1389@telpin.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alberto Bertogli <albertogli@telpin.com.ar>
In-Reply-To: <20030714140350.GB1389@telpin.com.ar>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

> --- Kconfig.orig	2003-07-14 10:32:06.000000000 -0300
> +++ Kconfig	2003-07-14 10:32:57.000000000 -0300
> @@ -147,7 +147,7 @@
>  	  unsure, say N.
>  
>  config	IP_VS_LBLC
> -	tristate "locality-based least-connection with replication scheduling"
> +	tristate "locality-based least-connection scheduling"
>          depends on IP_VS
>  	---help---
>  	  The locality-based least-connection scheduling algorithm is for
> @@ -163,7 +163,7 @@
>  	  unsure, say N.
>  
>  config  IP_VS_LBLCR
> -	tristate "locality-based least-connection with replication schedulin"
> +	tristate "locality-based least-connection with replication scheduling"
>          depends on IP_VS
>  	---help---
>  	  The locality-based least-connection with replication scheduling

Obviously correct. Dave, if you haven't already, please apply to your 
tree, thanks. We're working on the 2.4.x patch ;).

Best regards,
Roberto Nibali, ratz
-- 
echo '[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq'|dc
