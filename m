From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink_bond_slave: show mii_status only once
Date: Fri, 28 Feb 2014 10:14:11 -0800
Message-ID: <20140228101411.5048a69d@nehalam.linuxnetplumber.net>
References: <20140228135815.2C101E66B4@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:59040 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaB1SOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 13:14:14 -0500
Received: by mail-pb0-f43.google.com with SMTP id um1so1085479pbc.2
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 10:14:14 -0800 (PST)
In-Reply-To: <20140228135815.2C101E66B4@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Feb 2014 14:58:15 +0100 (CET)
Michal Kubecek <mkubecek@suse.cz> wrote:

> With "ip -d link show", bonding slave mii status is displayed
> twice, once as a number and once as a name.
> 
> Fixes: 730d3f61 ("iplink: add support for bonding slave")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  ip/iplink_bond_slave.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
> index bb4e1d6..8f3fc6c 100644
> --- a/ip/iplink_bond_slave.c
> +++ b/ip/iplink_bond_slave.c
> @@ -43,7 +43,6 @@ static void print_slave_mii_status(FILE *f, struct rtattr *tb)
>  {
>  	unsigned int status = rta_getattr_u8(tb);
>  
> -	fprintf(f, "mii_status %d ", status);
>  	if (status >= sizeof(slave_mii_status) / sizeof(slave_mii_status[0]))
>  		fprintf(f, "mii_status %d ", status);
>  	else

Applied
