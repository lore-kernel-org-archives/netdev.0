From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: add RTA_MARK support
Date: Mon, 23 Aug 2010 08:41:40 -0700
Message-ID: <20100823084140.3bd1dfe5@nehalam>
References: <1279705370.2452.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43863 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523Ab0HWPln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 11:41:43 -0400
In-Reply-To: <1279705370.2452.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jul 2010 11:42:50 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Adds support for RTA_MARK rt attribute added in linux-2.6.36
> 
> $ ip route get ADDR mark 4
> 192.168.20.110 dev eth1  src 192.168.20.108  mark 4
>     cache  mtu 1500 advmss 1460 hoplimit 64
> 
> $ ip route get 192.168.20.108 from ADDR iif STRING mark 256
> local 192.168.20.108 from 192.168.20.110 dev lo  src 192.168.20.108  mark 0x100
>     cache <local,src-direct>  iif eth1
> 
> $ ip route list cache [ADDR] mark NUMBER
> 
> Hexadecimal output if mark >= 16
> null marks are not displayed.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied

-- 
