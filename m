From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/isdn: checkng length to be sure not memory
 overflow
Date: Fri, 08 Mar 2013 00:36:40 -0500 (EST)
Message-ID: <20130308.003640.281567688999238934.davem@davemloft.net>
References: <5135BC3F.8070507@suse.cz>
	<513813F5.5040806@asianux.com>
	<51396845.3050600@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, jkosina@suse.cz, isdn@linux-pingi.de,
	gregkh@linuxfoundation.org, alan@linux.intel.com,
	netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab3CHFgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 00:36:42 -0500
In-Reply-To: <51396845.3050600@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Fri, 08 Mar 2013 12:25:41 +0800

> 
>   sizeof (cmd.parm.cmsg.para) is 50 (MAX_CAPI_PARA_LEN).
>   sizeof (cmd.parm) is 80+, but less than 100.
>   strlen(msg) may be more than 80+ (Modem-Commandbuffer, less than 255).
>     isdn_tty_send_msg is called by isdn_tty_parse_at
>     the relative parameter is m->mdmcmd (atemu *m)
>     the relative command may be "+M..."
> 
>   so need check the length to be sure not memory overflow.
>     cmd.parm is a union, and need keep original valid buffer length no touch
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Applied.
