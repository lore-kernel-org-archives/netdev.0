From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 02/26] phy: convert swphy register generation to tabular
 form
Date: Thu, 07 Jan 2016 11:47:54 -0800
Message-ID: <568EC0EA.20900@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5ziz-00074Z-Lp@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32820 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcAGTs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:48:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id cy9so266237115pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:48:28 -0800 (PST)
In-Reply-To: <E1a5ziz-00074Z-Lp@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> Convert the swphy register generation to tabular form which allows us
> to eliminate multiple switch() statements.  This results in a smaller
> object code size, more efficient, and easier to add support for faster
> speeds.
> 
> Before:
> 
> Idx Name          Size      VMA       LMA       File off  Algn
>   0 .text         00000164  00000000  00000000  00000034  2**2
> 
>    text    data     bss     dec     hex filename
>     388       0       0     388     184 swphy.o
> 
> After:
> 
> Idx Name          Size      VMA       LMA       File off  Algn
>   0 .text         000000fc  00000000  00000000  00000034  2**2
>   5 .rodata       00000028  00000000  00000000  00000138  2**2
> 
>    text    data     bss     dec     hex filename
>     324       0       0     324     144 swphy.o
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
