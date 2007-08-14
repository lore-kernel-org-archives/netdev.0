From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/18] ax88796 printk fixes
Date: Tue, 14 Aug 2007 01:35:02 -0400
Message-ID: <46C13F06.5080805@garzik.org>
References: <200708102105.l7AL5Lxg008974@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56258 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941819AbXHNFfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:35:03 -0400
In-Reply-To: <200708102105.l7AL5Lxg008974@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/ax88796.c: In function `ax_probe':
> drivers/net/ax88796.c:825: warning: size_t format, different type arg (arg 4)
> drivers/net/ax88796.c:825: warning: size_t format, different type arg (arg 5)
> 
> resource_size_t isn't size_t.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/ax88796.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)

applied


