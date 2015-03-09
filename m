From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: bcmgenet: xmit_more support
Date: Mon,  9 Mar 2015 14:52:15 -0700
Message-ID: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35942 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbbCIVwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:52:49 -0400
Received: by pdbnh10 with SMTP id nh10so74240394pdb.3
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:52:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch set adds support for xmit_more to the GENET driver, this is made
possible by first groupinng to a single location where we update the ring
producer index, and second by deferring the update of the producer index.

I would appreciate testing on chips that Jaedon and Petri are working on,
thanks!

Florian Fainelli (2):
  net: bcmgenet: update ring producer index and buffer count in xmit
  net: bcmgenet: add support for xmit_more

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

-- 
2.1.0
