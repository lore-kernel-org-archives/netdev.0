From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 14:44:56 -0400
Message-ID: <9e4733910709191144l6ddb66eaq84f3d1488bcf1443@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
	 <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
	 <20070918151622.GD32628@nd47.coderock.org>
	 <9e4733910709181217v417438s85bb9e6b4ad4b475@mail.gmail.com>
	 <20070919115621.GI32628@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: "Domen Puncer" <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:39362 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbXISSo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 14:44:56 -0400
Received: by rv-out-0910.google.com with SMTP id k20so262798rvb
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 11:44:56 -0700 (PDT)
In-Reply-To: <20070919115621.GI32628@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/19/07, Domen Puncer <domen@coderock.org> wrote:
> Patch at the end.
> When compiled as module use "modprobe fec_mpc52xx mac=foo",
> when built-in add to boot line: "fec_mpc52xx.mac=foo"

This patch series is working for me now.

This needs a cleanup too, but it is unrelated....

  CC      drivers/serial/mpc52xx_uart.o
drivers/serial/mpc52xx_uart.c: In function 'mpc52xx_console_setup':
drivers/serial/mpc52xx_uart.c:760: warning: format '%lx' expects type
'long unsigned int', but argument 2 has type 'resource_size_t'
drivers/serial/mpc52xx_uart.c: In function 'mpc52xx_uart_of_probe':
drivers/serial/mpc52xx_uart.c:978: warning: format '%lx' expects type
'long unsigned int', but argument 3 has type 'resource_size_t'



-- 
Jon Smirl
jonsmirl@gmail.com
