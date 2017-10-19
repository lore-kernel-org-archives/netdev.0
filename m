From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next 2/2] net: dsa: lan9303: Add fdb/mdb manipulation
Date: Thu, 19 Oct 2017 10:53:41 -0400
Message-ID: <87infbyyru.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no> <20171019121015.7395-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019121015.7395-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Add functions for managing the lan9303 ALR (Address Logic
> Resolution).
>
> Implement DSA methods: port_fdb_add, port_fdb_del, port_mdb_prepare,
> port_mdb_add and port_mdb_del.
>
> Since the lan9303 do not offer reading specific ALR entry, the driver
> caches all static entries - in a flat table.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

The comments I made in patch 1/2 apply here as well, please consider
them. Other than that, the patch looks good to me:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
