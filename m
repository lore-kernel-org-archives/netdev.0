From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Sat, 30 Dec 2006 10:23:58 +0900 (JST)
Message-ID: <20061230.102358.106876516.yoshfuji@linux-ipv6.org>
References: <20061217232311.f181302f.komurojun-mbn@nifty.com>
	<20061218030113.GT10316@stusta.de>
	<20061230185043.d31d2104.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, viro@ftp.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41368 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030210AbWL3BXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 20:23:20 -0500
To: komurojun-mbn@nifty.com
In-Reply-To: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061230185043.d31d2104.komurojun-mbn@nifty.com> (at Sat, 30 Dec 2006 18:50:43 +0900), Komuro <komurojun-mbn@nifty.com> says:

> I investigated the ftp-file-transfer-stop problem by git-bisect method,
> and found this problem was introduced by
> "[TCP]: MD5 Signature Option (RFC2385) support" patch.
> 
> Mr.YOSHIFUJI san, please fix this problem.

Hmm, have you try disabling CONFIG_TCP_MD5SIG?
(Is it already disabled?)

Are there any specific size of transfer to reproduce this?
Do you see similar issue with other simple application?

--yoshfuji
