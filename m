From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Sat, 30 Dec 2006 20:59:31 +0900
Message-ID: <20061230205931.9e430173.komurojun-mbn@nifty.com>
References: <20061217232311.f181302f.komurojun-mbn@nifty.com>
	<20061218030113.GT10316@stusta.de>
	<20061230185043.d31d2104.komurojun-mbn@nifty.com>
	<20061230.102358.106876516.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, viro@ftp.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:54428 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129AbWL3DBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 22:01:07 -0500
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061230.102358.106876516.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> > I investigated the ftp-file-transfer-stop problem by git-bisect method,
> > and found this problem was introduced by
> > "[TCP]: MD5 Signature Option (RFC2385) support" patch.
> > 
> > Mr.YOSHIFUJI san, please fix this problem.
> 
> Hmm, have you try disabling CONFIG_TCP_MD5SIG?
> (Is it already disabled?)

This problem happens both CONFIG_TCP_MD5SIG is disabled and enabled.

> Are there any specific size of transfer to reproduce this?

When I do ftp 40Mbytes file for 5-times or more,
 this problem happens.


> Do you see similar issue with other simple application?

sorry, I don't reproduce this problem on other application.

Thanks,

Best Regards
Komuro.
