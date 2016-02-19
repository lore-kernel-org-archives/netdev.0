From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH]fmvj18x_cs: The MAC address of FMV-J182 is stored at
 buf[5].
Date: Fri, 19 Feb 2016 15:52:33 +0300
Message-ID: <56C71011.2020509@cogentembedded.com>
References: <20160219213835.c16a60105e0342ff64b7b8aa@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Ken Kawasaki <ken_kawasaki@nifty.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36118 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175AbcBSMwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 07:52:35 -0500
Received: by mail-lf0-f43.google.com with SMTP id 78so52952419lfy.3
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 04:52:34 -0800 (PST)
In-Reply-To: <20160219213835.c16a60105e0342ff64b7b8aa@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/19/2016 3:38 PM, Ken Kawasaki wrote:

> The MAC address of FMV-J182 is stored at buf[5].
>
> Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>
>
> ---
>
> --- linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c.orig	2016-02-19 20:48:40.143852346 +0900
> +++ linux-4.4.1/drivers/net/ethernet/fujitsu/fmvj18x_cs.c	2016-02-19 20:54:52.345568822 +0900
> @@ -469,8 +469,8 @@ static int fmvj18x_config(struct pcmcia_
>   		    goto failed;
>   	    }
>   	    /* Read MACID from CIS */
> -	    for (i = 5; i < 11; i++)
> -		    dev->dev_addr[i] = buf[i];
> +	    for (i = 0; i < 6; i++)
> +		    dev->dev_addr[i] = buf[i+5];

    Be consistent please, surround + with spaces.

[...]

MBR, Sergei
