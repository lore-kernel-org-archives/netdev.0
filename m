From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sun, 30 Jul 2006 14:29:22 -0700
Message-ID: <20060730142922.7c1d4f7d@localhost.localdomain>
References: <200607302138.02855.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Pekka Savola <pekkas@netcore.fi>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8867 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932348AbWG3Vat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 17:30:49 -0400
To: Jesper Juhl <jesper.juhl@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <200607302138.02855.jesper.juhl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Jul 2006 21:38:02 +0200
Jesper Juhl <jesper.juhl@gmail.com> wrote:

> There's an obvious memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
> We are not freeing 'tbuf' on error.
> Patch below fixes that.
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Agreed, thanks for catching it.  The whole kfifo interface is kind of
annoying have to do an extra copy.
