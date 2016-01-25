From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Mon, 25 Jan 2016 17:24:48 +0100
Message-ID: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:33472 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbcAYQYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 11:24:50 -0500
Received: by mail-lb0-f181.google.com with SMTP id x4so77711213lbm.0
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 08:24:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As subject says, 802.3ad bonding is not working with virtio network model.

The only errors I see is:

No 802.3ad response from the link partner for any adapters in the bond.

Dumping the network traffic shows that no LACP packets are sent from the
host running with virtio driver, changing to for example e1000 solves
this problem
with no configuration changes.

Is this a known problem?

-- 
Bj(/)rnar
