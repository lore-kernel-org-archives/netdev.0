From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.26] drivers/net/bonding/bond_main.c - remove	unnecessary
 #define
Date: Sat, 12 Apr 2008 05:01:44 -0400
Message-ID: <48007A78.6090800@pobox.com>
References: <1207863571.1020.196.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chad Tindel <ctindel@users.sourceforge.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	David S Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59376 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758426AbYDLJBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:01:54 -0400
In-Reply-To: <1207863571.1020.196.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> bond_main.c already #includes <linux/seq_file.h>
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
>  drivers/net/bonding/bond_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index ecfaf14..6e91b4b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3065,8 +3065,6 @@ out:
>  
>  #ifdef CONFIG_PROC_FS
>  
> -#define SEQ_START_TOKEN ((void *)1)
> -
>  static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
>  {
>  	struct bonding *bond = seq->private;

applied


