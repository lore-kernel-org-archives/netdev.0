From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: Re: [PATCH 13/23 v3] mlx4: Unicast Loopback support
Date: Tue, 16 Feb 2010 08:45:43 +0200
Message-ID: <15ddcffd1002152245l76e85d8dx31298a420fd815ef@mail.gmail.com>
References: <4B72E7DF.3010206@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	liranl@mellanox.co.il, Tziporet Koren <tziporet@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:47150 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab0BPGpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 01:45:45 -0500
Received: by bwz5 with SMTP id 5so1648910bwz.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 22:45:43 -0800 (PST)
In-Reply-To: <4B72E7DF.3010206@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> Or Gerlitz [or.gerlitz@gmail.com] wrote:

>> I wasn't sure what is the use case here, isn't loopback handled by higher levels at the network stack?

> The use case is two VMs using the same physical adapter.

I am still not with you: are you referring to the case where each VM
is being served by a
different VF? in that case, the VF driver (mlx4_en) has no way to know
its a "loopback" packet,
and switching between VFs can be programmed to the PF by the PF driver
(modified mlx4_core).

If you are talking to the case both VMs are being served by the same
PCI function --> same NIC
then again, loopback is handled in higher level.

Is there a 3rd use case?

Or.
