From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH][iproute2] Detect 6rd kernel missing support / 6rd
 tunnel scope
Date: Mon, 12 Apr 2010 11:46:17 -0700
Message-ID: <20100412114617.2afaf0a0@nehalam>
References: <20100404204014.GA24602@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59751 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130Ab0DLSqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 14:46:34 -0400
In-Reply-To: <20100404204014.GA24602@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 Apr 2010 22:40:14 +0200
Alexandre Cassen <acassen@freebox.fr> wrote:

> This patch fix two issues:
> 
> * If kernel is not supporting 6rd then ioctl() call
>   will return EINVAL, if so just skip perror call.
> 
> * 6rd scope is ipv6/ip tunnels. Dont try to fetch
>   6rd tunnel parms if tunnel protocol != IPPROTO_IPV6.
> 
> Signed-off-by: Alexandre Cassen <acassen@freebox.fr>

Applied thanks.
