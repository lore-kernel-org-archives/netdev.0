From: Dan Streetman <dan.streetman@canonical.com>
Subject: for stable: vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices
Date: Thu, 19 May 2016 21:53:33 -0400
Message-ID: <CAOZ2QJM1F4HDYESBSbyhf9=20H7Z7v3fCxo=Q5U9CMUnjnURMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:35024 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbcETByO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 21:54:14 -0400
Received: by mail-yw0-f178.google.com with SMTP id g133so96476738ywb.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:54:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you queue this 3-commit patch series for stable?

7e059158d57b79159eaf1f504825d19866ef2c42 ("vxlan, gre, geneve: Set a
large MTU on ovs-created tunnel devices")
55e5bfb53cff286c1c1ff49f51325dc15c7fea63 ("geneve: Relax MTU constraints")
72564b59ffc438ea103b0727a921aaddce766728 ("vxlan: Relax MTU constraints")

Without them certain ovs-created tunnels have mtus that are too low
and can't be increased past 1500, even if both endpoints of the tunnel
have larger mtus, causing silently dropped large packets.

They fix:
b2acd1dc3949cd60c571844d495594f05f0351f4 (for gre),
614732eaa12dd462c0ab274700bed14f36afea5e (for ovs vxlan), and
2d07dc79fe04a43d82a346ced6bbf07bdb523f1b (for geneve).
