From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 03/25] [net] BUG to BUG_ON changes
Date: Tue, 10 Mar 2009 13:23:55 +0300
Message-ID: <20090310102355.GB2248@x200.localdomain>
References: <1236661850-8237-1-git-send-email-stoyboyker@gmail.com> <1236661850-8237-2-git-send-email-stoyboyker@gmail.com> <1236661850-8237-3-git-send-email-stoyboyker@gmail.com> <1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stoyan Gaydarov <stoyboyker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:56212 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbZCJKRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 06:17:00 -0400
Content-Disposition: inline
In-Reply-To: <1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 12:10:28AM -0500, Stoyan Gaydarov wrote:
> --- a/drivers/net/pppol2tp.c
> +++ b/drivers/net/pppol2tp.c
> @@ -1222,8 +1222,7 @@ static void pppol2tp_tunnel_closeall(struct pppol2tp_tunnel *tunnel)
>  	struct pppol2tp_session *session;
>  	struct sock *sk;
>  
> -	if (tunnel == NULL)
> -		BUG();
> +	BUG_ON(tunnel == NULL);

NAK, should be deleted, and kernel will oops anyway.

>  	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
>  	       "%s: closing all sessions...\n", tunnel->name);
