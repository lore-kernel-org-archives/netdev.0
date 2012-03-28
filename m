From: Thomas Voegtle <tv@lio96.de>
Subject: bridge + vlan + igmp snooping
Date: Wed, 28 Mar 2012 17:16:38 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1203281711160.18105@er-systems.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from er-systems.de ([46.4.18.139]:32837 "EHLO er-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758039Ab2C1P1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 11:27:15 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by er-systems.de (Postfix) with ESMTP id 725EF2CF9A9
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 17:16:39 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by er-systems.de (Postfix) with ESMTPS id 44AA92CF91E
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 17:16:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I tried multicast in vlan on a bridge with BRIDGE_IGMP_SNOOPING 
swtiched on and it didn't work.

Switching off snooping helps (echo 0 > /sys..) or switching off vlan.
Tested on latest 3.0 and 3.2.

Is there a known issue?

Thanks,
  Thomas
