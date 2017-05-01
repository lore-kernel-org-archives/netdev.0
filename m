From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] switchdev: documentation: fix whitespace issues
Date: Mon, 1 May 2017 19:50:15 +0200
Message-ID: <d39c076d-b367-c493-2cb6-a892f8534c20@redhat.com>
References: <20170501150201.18959-1-slemieux.tyco@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Sylvain Lemieux <slemieux.tyco@gmail.com>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750732AbdEARuS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 13:50:18 -0400
In-Reply-To: <20170501150201.18959-1-slemieux.tyco@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1.5.2017 17:02, Sylvain Lemieux wrote:
> From: Liam Beguin <lbeguin@tycoint.com>
> 
> Figure 1 is full of whitespaces; fix it
> 
> Signed-off-by: Liam Beguin <lbeguin@tycoint.com>
> Signed-off-by: Sylvain Lemieux <slemieux@tycoint.com>
> ---
>  Documentation/networking/switchdev.txt | 70 +++++++++++++++++-----------------
>  1 file changed, 35 insertions(+), 35 deletions(-)
> 
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> index 2bbac05ab9e2..3e7b946dea27 100644
> --- a/Documentation/networking/switchdev.txt
> +++ b/Documentation/networking/switchdev.txt
> @@ -13,43 +13,43 @@ an example setup using a data-center-class switch ASIC chip.  Other setups
>  with SR-IOV or soft switches, such as OVS, are possible.
>  
>  
> -                             User-space tools                                 
> -                                                                              
> -       user space                   |                                         
> -      +-------------------------------------------------------------------+   
> -       kernel                       | Netlink                                 
> -                                    |                                         
> -                     +--------------+-------------------------------+         
> -                     |         Network stack                        |         
> -                     |           (Linux)                            |         
> -                     |                                              |         
> -                     +----------------------------------------------+         
> -                                                                              
> +                             User-space tools
> +
> +       user space                   |
> +      +-------------------------------------------------------------------+
> +       kernel                       | Netlink
> +                                    |
> +                     +--------------+-------------------------------+
> +                     |         Network stack                        |
> +                     |           (Linux)                            |
> +                     |                                              |
> +                     +----------------------------------------------+
> +
>                             sw1p2     sw1p4     sw1p6
> -                      sw1p1  +  sw1p3  +  sw1p5  +          eth1             
> -                        +    |    +    |    +    |            +               
> -                        |    |    |    |    |    |            |               
> -                     +--+----+----+----+-+--+----+---+  +-----+-----+         
> -                     |         Switch driver         |  |    mgmt   |         
> -                     |        (this document)        |  |   driver  |         
> -                     |                               |  |           |         
> -                     +--------------+----------------+  +-----------+         
> -                                    |                                         
> -       kernel                       | HW bus (eg PCI)                         
> -      +-------------------------------------------------------------------+   
> -       hardware                     |                                         
> -                     +--------------+---+------------+                        
> -                     |         Switch device (sw1)   |                        
> -                     |  +----+                       +--------+               
> -                     |  |    v offloaded data path   | mgmt port              
> -                     |  |    |                       |                        
> -                     +--|----|----+----+----+----+---+                        
> -                        |    |    |    |    |    |                            
> -                        +    +    +    +    +    +                            
> +                      sw1p1  +  sw1p3  +  sw1p5  +          eth1
> +                        +    |    +    |    +    |            +
> +                        |    |    |    |    |    |            |
> +                     +--+----+----+----+-+--+----+---+  +-----+-----+
> +                     |         Switch driver         |  |    mgmt   |
> +                     |        (this document)        |  |   driver  |
> +                     |                               |  |           |
> +                     +--------------+----------------+  +-----------+
> +                                    |
> +       kernel                       | HW bus (eg PCI)
> +      +-------------------------------------------------------------------+
> +       hardware                     |
> +                     +--------------+---+------------+
> +                     |         Switch device (sw1)   |
> +                     |  +----+                       +--------+
> +                     |  |    v offloaded data path   | mgmt port
> +                     |  |    |                       |
> +                     +--|----|----+----+----+----+---+
> +                        |    |    |    |    |    |
> +                        +    +    +    +    +    +
>                         p1   p2   p3   p4   p5   p6
> -                                       
> -                             front-panel ports                                
> -                                                                              
> +
> +                             front-panel ports
> +
>  
>                                      Fig 1.
>  
> 

Acked-by: Ivan Vecera <ivecera@redhat.com>
