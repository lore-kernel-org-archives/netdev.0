From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 0/2] 6lowpan: fixes for new reassembly implementation
Date: Wed,  5 Mar 2014 21:43:29 +0100
Message-ID: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:40046 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556AbaCEUog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 15:44:36 -0500
Received: by mail-ea0-f175.google.com with SMTP id d10so1278919eaj.6
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 12:44:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I detected a embarrassing mistake of registering sysctl interface while
init fragmentation. This is fixed in Patch 1/2
(6lowpan: reassembly: fix return of init function).

The second issue occurs while reassembly and unloading 6lowpan module.
I am definitively sure about if I fixed it correctly in this case.
The problem is there are some running timers which are not deleted after
unloading the 6lowpan module. This issue is fixed in Patch 2/2
(6lowpan: reassembly: fix kernel oops while unloading).

- Alex

Alexander Aring (2):
  6lowpan: reassembly: fix return of init function
  6lowpan: reassembly: fix kernel oops while unloading

 net/ieee802154/reassembly.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

-- 
1.9.0
