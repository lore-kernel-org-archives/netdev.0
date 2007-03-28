From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPv6: Connection reset/timeout under heavy load
Date: Wed, 28 Mar 2007 18:23:34 +0900 (JST)
Message-ID: <20070328.182334.109744556.yoshfuji@linux-ipv6.org>
References: <4608E7CA.3090001@ripe.net>
	<20070327.194636.63219035.yoshfuji@linux-ipv6.org>
	<460A2BDB.6080200@ripe.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: agoston@ripe.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35323 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965404AbXC1JWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 05:22:48 -0400
In-Reply-To: <460A2BDB.6080200@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <460A2BDB.6080200@ripe.net> (at Wed, 28 Mar 2007 10:48:27 +0200), Agoston Horvath <agoston@ripe.net> says:

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Would you test with latest kernel, if possible, please?
> 
> For the archive: switching to 2.6.20.4 fixed this problem.

Thank you for your report.

I guess the following change will fix the issue for 2.6.16.y:
http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/yoshfuji/linux-2.6-fix.git;a=commit;h=33a79bba0cc2f197b46cc54182f94c31ff6ad334

I hope this patch will go in 2.6.16-stable...

Regards,

--yoshfuji
