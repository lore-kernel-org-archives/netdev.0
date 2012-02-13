From: Li Wei <lw@cn.fujitsu.com>
Subject: Question with commit 299b0767(ipv6: Fix IPsec slowpath fragmentation
 problem)
Date: Mon, 13 Feb 2012 16:10:39 +0800
Message-ID: <4F38C57F.5000706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49458 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab2BMIKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 03:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Steffen!

I found some problem while doing networking tests with IPSec that
the first fragment doesn't use the max MTU to fill payload, but with
20 bytes smaller. When I reverted your commit 299b0767(ipv6: Fix 
IPsec slowpath fragmentation problem), things goes well.

Would you so kindly to point me out what the commit did, because I
think the original implementation had taken IPSec header and tailer
into account.

Thanks!
