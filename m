From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] sis900_mii_probe() must be __devinit
Date: Tue, 10 Jul 2007 12:25:57 -0400
Message-ID: <4693B315.3090601@garzik.org>
References: <20070710124435.GR3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59983 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755670AbXGJQ0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:26:01 -0400
In-Reply-To: <20070710124435.GR3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch fixes the following section mismatch:
> 
> <--  snip  -->
> 
> ...
>   MODPOST vmlinux
> WARNING: drivers/built-in.o(.text+0x298170): Section mismatch: reference to .init.text:sis900_mii_probe (between 'sis900_probe' and 'sis900_default_phy')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


