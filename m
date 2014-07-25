From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 0/8] Backport to stable-3.4 for fix CVE-2014-0181
Date: Fri, 25 Jul 2014 16:22:21 +0800
Message-ID: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:34868 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759859AbaGYIXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:23:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

Hi David,

This backport fix CVE-2014-0181 which would still be vulnerable in
stable-3.4, please add it.

patchset from 5187cd055b6e to 90f62cf30a78 fixed CVE-2014-0181,
which can't backport to stable-3.4 directly, 

Those three patches are needed:
commit 935d8aabd4331f47a89c3e1daa5779d23cf244ee 
commit 038e7332b8d4c0629a2965e3ede1a92e8e427bd6
commit 3fbc290540a1ed1a8a076ed8f53bee7a38a9f408 

and this patch is unneeded:
commit a53b72c83a4216f2eb883ed45a0cbce014b8e62d

v2:
1) Add the patch:
   commit 2d7a85f4b06e9c27ff629f07a524c48074f07f81
   which fixes this series to not break applications like Zebra.

2) Change the From: to the original author.

 -- 
1.7.12
