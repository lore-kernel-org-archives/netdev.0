From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Mon, 29 Sep 2008 15:14:10 -0500
Message-ID: <2acbd3e40809291314t41b6f765k9aa7809ca21bd88d@mail.gmail.com>
References: <20080929133305.GA10554@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Andy Fleming" <afleming@freescale.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Alexandr Smirnov" <asmirnov@ru.mvista.com>
To: "Wang Jian" <lark@linux.net.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:62134 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbYI2UOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 16:14:12 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2287090wfd.4
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 13:14:11 -0700 (PDT)
In-Reply-To: <20080929133305.GA10554@debian>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 8:33 AM, Wang Jian <lark@linux.net.cn> wrote:
> Hi,
>
> During my testing, I found that 88e1111 can't get out of sleep mode
> (Energy detect+) in certain condition.
>
> I am working on a mpc8541 board, with TSEC (gianfar) connected to 88e1111
> phy chip. The kenrel is 2.6.26-rc8 with several patches.
>
> The following steps can 100% trigger the problem
>
> 1. unplug cable from tsec interfaces (eth0/eth1 in my case)
> 2. boot up and waiting for 6+ seconds
> 3. ifconfig eth0 up
> 4. plug in cable, the link can't be established and no way to bring it
>   up


Is anything printed out to the log?

Are you polling or using an interrupt?

If you are using an interrupt, is it firing?

If you are polling, can you print out some debug information to see if
it is successfully reading the PHY status?


Andy
