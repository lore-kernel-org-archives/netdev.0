From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 0/2] net: dsa: lan9303: Add fdb/mdb methods
Date: Fri, 20 Oct 2017 10:03:18 -0400
Message-ID: <87d15h29y1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171020101910.2245-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020101910.2245-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

It looks much cleaner, thanks!

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> This series add support for accessing and managing the lan9303 ALR 
> (Address Logic Resolution). 
>
> The first patch add low level functions for accessing the ALR, along
> with port_fast_age and port_fdb_dump methods.
>
> The second patch add functions for managing ALR entires, along with
> remaining fdb/mdb methods. 
>
> Note that to complete STP support, a special ALR entry with the STP eth
> address must be added too. This must be addressed later.
>
> Comments welcome!
>
>
> Changes v2 -> v3:
>  - Whitespace polishing. Removed some "section" comments.
>  - Prefixed ALR constants with LAN9303_ for consistency.
>  - Patch 2: lan9303_port_fast_age() wrap the "port" into a struct for passing
>    as context to alr_loop_cb_del_port_learned. Safer in event of type change.
>  - Patch 2: Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

You'll usually directly add the Reviewed-by: tags right under your
Signed-off-by: tag of the concerned patches in next iterations.

(don't worry though I've added it back to patch 2/2.)


Thanks,

        Vivien
