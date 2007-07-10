From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2,6 patch] sunhme.c:quattro_pci_find() must be __devinit
Date: Tue, 10 Jul 2007 12:45:55 -0400
Message-ID: <4693B7C3.7090507@garzik.org>
References: <20070710124449.GZ3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60249 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303AbXGJQp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:45:58 -0400
In-Reply-To: <20070710124449.GZ3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch fixes the following section mismatch:
> 
> <--  snip  -->
> 
> ...
>   MODPOST vmlinux
> WARNING: drivers/built-in.o(.text+0x272f8b): Section mismatch: reference to .init.text:quattro_pci_find (between 'happy_meal_pci_probe' and 'happy_meal_pci_remove')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


