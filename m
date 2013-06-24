From: Pawit Pornkitprasan <p.pawit@gmail.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Tue, 25 Jun 2013 07:45:33 +0900
Message-ID: <CAJA5wJRW1gai3pRXRD1fugrXQJxsJ3PDzVkLqWqjxvF-ixAheg@mail.gmail.com>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
	<CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ryousei Takano <takano-ryousei@aist.go.jp>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:42865 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3FXWpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 18:45:34 -0400
Received: by mail-ie0-f175.google.com with SMTP id a13so25901103iee.20
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 15:45:33 -0700 (PDT)
In-Reply-To: <CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 25, 2013 at 4:42 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> Pawit,
>
> As Greg indicdated, this (== stetting a bridge over a PF or VF in
> SRIOV moded) can actually work, if you make sure to use FDB operations
> to add the VM unicast MAC to the uplink (the mellanox device) tables,
> this is trivial (google for ndo_fdb_add ...) and should work, let us
> know if it doesn't.
>

Thank you. I will try it out.

>
> so on 3.10 it "just" doesn't work (but should as I explained above)
> but on 3.8 you're crashing? can you send the oops listings?
>

It just doesn't work on both kernels.

Thank you for your replies,
Pawit
