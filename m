From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: 2.6.23-rc regression: bcm43xx does not work after commit 4cf92a3c
Date: Mon, 17 Sep 2007 04:24:18 +0900 (JST)
Message-ID: <20070917.042418.19962472.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net, jeff@garzik.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44064 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbXIPTWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 15:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

With latest git tree, bcm43xx driver does not work.
By bisect, I've found the commit 4cf92a3c is the first "bad" commit.

    [PATCH] softmac: Fix ESSID problem

    Victor Porton reported that the SoftMAC layer had random problem when setting the ESSID :
    http://bugzilla.kernel.org/show_bug.cgi?id=8686 After investigation, it turned out to be
    worse, the SoftMAC layer is left in an inconsistent state. The fix is pretty trivial.
    
    Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
    Acked-by: Michael Buesch <mb@bu3sch.df>
    Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

After reverting this commit, the driver starts working again.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
