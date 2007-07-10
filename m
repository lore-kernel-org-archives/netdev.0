From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] rrunner.c:rr_init() must be __devinit
Date: Tue, 10 Jul 2007 12:26:18 -0400
Message-ID: <4693B32A.2050106@garzik.org>
References: <20070710124447.GY3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59991 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760728AbXGJQ0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:26:19 -0400
In-Reply-To: <20070710124447.GY3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch fixes the following section mismatch:
> 
> <--  snip  -->
> 
> ...
>   MODPOST vmlinux
> WARNING: drivers/built-in.o(.text+0x26e3f2): Section mismatch: reference to .init.text:rr_init (between 'rr_init_one' and 'rr_remove_one')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


