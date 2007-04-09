From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [iputils] Re-probe at same TTL after MTU reduction.
Date: Mon, 09 Apr 2007 13:17:45 +0900 (JST)
Message-ID: <20070409.131745.88509839.yoshfuji@linux-ipv6.org>
References: <1175624435275-git-send-email-jheffner@psc.edu>
	<11756244353377-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40974 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbXDIEQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 00:16:47 -0400
In-Reply-To: <11756244353377-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <11756244353377-git-send-email-jheffner@psc.edu> (at Tue,  3 Apr 2007 14:20:35 -0400), John Heffner <jheffner@psc.edu> says:

> This fixes a bug that would miss a hop after an ICMP packet too big message,
> since it would continue increase the TTL without probing again.

Applied, thanks.

--yoshfuji
