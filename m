From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.4-rc2-bk4 2/2] pcnet32 use netif_msg_init
Date: Mon, 08 Mar 2004 21:19:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404D29B7.6070005@pobox.com>
References: <200403081946.i28Jkrb10646@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200403081946.i28Jkrb10646@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> @@ -2013,8 +2016,7 @@
>  {
>      printk(KERN_INFO "%s", version);
>  
> -    if (debug >= 0 && debug < (sizeof(int) - 1))
> -	pcnet32_debug = 1 << debug;
> +    pcnet32_debug = netif_msg_init(debug, 0);


Do you really want to default to silence?  IMO define a 
PCNET32_DEF_MSG_ENABLE with a few of the critical bits like probe-time 
information.

	Jeff
