From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH 1/1 v2] isdn: Use kernel_{send,recv}msg instead of open coding
Date: Fri, 22 May 2009 17:47:37 +0200
Message-ID: <200905221747.38036.isdn@linux-pingi.de>
References: <20090522153723.GA26133@ghostprotocols.net>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, paul.moore@hp.com,
	netdev@vger.kernel.org, vanhoof@redhat.com, williams@redhat.com,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:64417 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbZEVPrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 11:47:41 -0400
In-Reply-To: <20090522153723.GA26133@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaldo,

thanks for the patch, I will ack it and send it with the other mISDN s in one 
series later today.

Dave please wait, until you get my patchseries, since some context changes
are needed to aplly together with the other patches.


On Freitag, 22. Mai 2009 17:37:24 Arnaldo Carvalho de Melo wrote:
> Hi David,
>
> 	I've fixed it up and did a make allmodconfig, no problems, I
> think this time it is OK.
>
> $ rm -f ../allmodconfig/drivers/isdn/mISDN/l1oip_core.o
> $ make O=../allmodconfig drivers/isdn/mISDN/l1oip_core.o
>   Using /home/acme_unencrypted/git/linux-2.6-tip as source for kernel
>   GEN     /home/acme_unencrypted/git/allmodconfig/Makefile
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   SYMLINK include/asm -> include/asm-x86
>   CALL    /home/acme_unencrypted/git/linux-2.6-tip/scripts/checksyscalls.sh
>   CC      drivers/isdn/mISDN/l1oip_core.o
> $
>
> Regards,
>
> - Arnaldo
>
> commit cbe24f5d80209776a7e033c92a5882227a8360e6
> Author: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date:   Fri May 22 12:32:05 2009 -0300
>
>     isdn: Use kernel_{send,recv}msg instead of open coding
>
>     Reducing the number of direct users of sock_{recv,send}msg.
>
>     Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>
...

