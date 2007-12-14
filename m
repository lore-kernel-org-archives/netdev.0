From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/s2io.c section fixes
Date: Fri, 14 Dec 2007 15:28:19 -0500
Message-ID: <4762E763.5070800@pobox.com>
References: <20071211222306.GV14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33949 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756075AbXLNU2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 15:28:37 -0500
In-Reply-To: <20071211222306.GV14204@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> Code used by the non-__devinit s2io_open() mustn't be __devinit.
> 
> This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:
> 
> <--  snip  -->
> 
> ...
> WARNING: vmlinux.o(.text+0x6f6e3e): Section mismatch: reference to .init.text.20:s2io_test_intr (between 's2io_open' and 's2io_ethtool_sset')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/s2io.c |    4 ++--

applied #upstream-fixes


