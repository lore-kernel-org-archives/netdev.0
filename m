From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Mon, 26 Mar 2012 12:49:42 -0700
Message-ID: <CAL1RGDV2JUhq-pzeTXMwSM8ZO4oH-WMb5kmdytDLVtaw8=6jFA@mail.gmail.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com> <1332752874-8086-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:52306 "HELO
	na3sys010aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751136Ab2CZTuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 15:50:05 -0400
Received: by mail-gx0-f174.google.com with SMTP id e5so5532113ggh.33
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 12:50:02 -0700 (PDT)
In-Reply-To: <1332752874-8086-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 2:07 AM, Amir Vadai <amirv@mellanox.com> wrote:
> Values in Mbps units.

Hopefully not nitpicking too much, but Mbps still seems to coarse to me.
Eg in wireless world I can imagine wanting to limit a tos to a small # of kbps.

If this is done through netlink, the ABI can use a small unit and then tc
can accept abbreviations for kbps / Mbps / Gbps?

 - R.
