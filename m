From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Sat, 30 Dec 2006 23:19:52 +0900 (JST)
Message-ID: <20061230.231952.16573563.yoshfuji@linux-ipv6.org>
References: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
	<20061230.102358.106876516.yoshfuji@linux-ipv6.org>
	<20061230205931.9e430173.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, viro@ftp.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41384 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbWL3OTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Dec 2006 09:19:13 -0500
To: komurojun-mbn@nifty.com
In-Reply-To: <20061230205931.9e430173.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061230205931.9e430173.komurojun-mbn@nifty.com> (at Sat, 30 Dec 2006 20:59:31 +0900), Komuro <komurojun-mbn@nifty.com> says:

> > Do you see similar issue with other simple application?
> 
> sorry, I don't reproduce this problem on other application.

Can you reproduce it with other ftp client and/or server?


Anyway...

Please provide the output of "netstat -na" command during the
transfer, and the output of "lsmod | grep conntrack" (just for
sure).


More questions:

What kind of mode do you use? e.g. PORT/EPRT/LPRT/PASV/EPSV/LPSV

When the transfer get stuck, are other communication still working?

Are there any workaround?
e.g. stop-start vsftpd cycle, ifdown-ifup cycle, rmmod/insmod cycle etc.


Regards,

--yoshfuji
