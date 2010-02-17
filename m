From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 13/23 v3] mlx4: Unicast Loopback support
Date: Wed, 17 Feb 2010 14:15:51 +0200
Message-ID: <15ddcffd1002170415k30b47d70tb055945f5478a366@mail.gmail.com>
References: <4B7AB9A6.1090209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61800 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab0BQMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 07:15:53 -0500
Received: by bwz19 with SMTP id 19so5406634bwz.28
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 04:15:51 -0800 (PST)
In-Reply-To: <4B7AB9A6.1090209@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> I am referring to the case where two VMs are served by two different VFs. The HW checks this field and decides
> whether the packet is loopback or not (by checking whether the written mac matches one of the registered macs on this device).

okay good. I'd be glad to understand what setting/instrumentation has
to be made to the PF driver code to allow for VF/VF traffic to be
either internally switched by the PF HW or be forwarded to the PF
uplink for external switch doing the job (VEPA mode).

I don't think you have to explicitly allow this in the initial
patchset, just try to make it easy to patch.

Or.
