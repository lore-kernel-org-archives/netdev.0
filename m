From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] bonding netpoll implementation
Date: Wed,  4 Mar 2015 18:26:36 -0800
Message-ID: <1425522396-3472-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:33984 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbbCEC0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 21:26:41 -0500
Received: by pdev10 with SMTP id v10so693876pde.1
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 18:26:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the patch that I deferred from the previous patch series because
of the locking concerns. I took some time to test the implementation and
confirmed / resolved remaining outstanding issues (mostly locking related)
and tested for RCU annotation / sparse warnings and looked for other 
type of warnings with debug enabled kernel while using netconsole. 

Mahesh Bandewar (1):
  bonding: implement bond_poll_controller()

 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

-- 
2.2.0.rc0.207.ga3a616c
