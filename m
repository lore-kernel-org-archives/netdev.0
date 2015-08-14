From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next] infamous dev refcnt leak... again.
Date: Fri, 14 Aug 2015 14:14:54 -0700
Message-ID: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35943 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbHNVO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 17:14:56 -0400
Received: by pdco4 with SMTP id o4so35125958pdc.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 14:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While rebooting host running latest net-next

 unregister_netdevice: waiting for eth0 to become free. Usage count = 4

Oh well...
