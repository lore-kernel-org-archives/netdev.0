From: Komuro <komurojun-mbn@nifty.com>
Subject: RE: [PATCH] pcmcia: worklimit reaches -1
Date: Fri, 27 Feb 2009 06:37:17 +0900
Message-ID: <20090227063717.cb97eda7.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg500.nifty.com ([202.248.238.127]:43821 "EHLO
	defg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbZBZVvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 16:51:13 -0500
Received: from userg502.nifty.com (userg502p.nifty.com [172.22.128.82])by defg500.nifty.com with ESMTP id n1QLaOhJ026500
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 06:36:24 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In 3c574_cs.c, 
workslimit becomes -2 ,so it works.
 
>		if (--work_budget < 0) {
>			...
>		break;

el3_interrupt() returns true, if it handled at least one interrupt.

Best Regards
Komuro

