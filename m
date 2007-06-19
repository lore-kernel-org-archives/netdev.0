From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE]: Fix symbolic link to tc-bfifo.8
Date: Tue, 19 Jun 2007 16:30:27 -0700
Message-ID: <20070619163027.75ec852a@localhost.localdomain>
References: <200706180216.l5I2Ghax000887@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53801 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756556AbXFSXcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:32:08 -0400
In-Reply-To: <200706180216.l5I2Ghax000887@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 11:16:42 +0900 (JST)
Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp> wrote:

> 
> tc-pbfifo.8 does not exist because it was moved to tc-bfifo.8.
> 
> Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
> ---
>  Makefile |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index dbcb249..af0d5e4 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -52,8 +52,7 @@ install: all
>  	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
>  	install -m 0755 -d $(DESTDIR)$(MANDIR)/man8
>  	install -m 0644 $(shell find man/man8 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man8
> -	ln -sf tc-pbfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-bfifo.8
> -	ln -sf tc-pbfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
> +	ln -sf tc-bfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
>  	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
>  	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
>  
applied thanks

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
