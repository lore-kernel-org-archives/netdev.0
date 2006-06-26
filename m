From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] s2io: netpoll support
Date: Mon, 26 Jun 2006 12:33:46 -0400
Message-ID: <44A00C6A.9020602@hp.com>
References: <001801c69634$6d3b33a0$4110100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	"'Ananda. Raju (E-mail)'" <ananda.raju@neterion.com>,
	"'Leonid. Grossman (E-mail)'" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:41442 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750765AbWFZQds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 12:33:48 -0400
To: ravinandan.arakali@neterion.com
In-Reply-To: <001801c69634$6d3b33a0$4110100a@pc.s2io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Since the poll_controller entry point will be used by utilities such as
> netdump, I am thinking we need to clear Tx interrupts as well here.
> Did you get a chance to test this patch with netdump ?

No, I've only been testing Kgdb over Ethernet on Debian, I think netdump 
is a Red Hat thing.  I can test any changes you'd want to make with this 
patch if you post the diffs.

-Brian


> -----Original Message-----
> From: Brian Haley [mailto:brian.haley@hp.com]
> Sent: Thursday, June 15, 2006 11:37 AM
> To: netdev@vger.kernel.org
> Cc: ravinandan.arakali@neterion.com; jgarzik@pobox.com; Ananda. Raju
> (E-mail); Leonid. Grossman (E-mail)
> Subject: Re: [PATCH] s2io: netpoll support
> 
> 
> This adds netpoll support for things like netconsole/kgdboe to the s2io
> 10GbE driver.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
