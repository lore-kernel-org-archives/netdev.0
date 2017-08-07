From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: lan9303: Only allocate 3 ports
Date: Mon, 07 Aug 2017 19:10:39 -0400
Message-ID: <87wp6fm0sw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Save 2628 bytes on arm eabi by allocate only the required 3 ports.
>
> Now that ds->num_ports is correct: In net/dsa/tag_lan9303.c
> eliminate duplicate LAN9303_MAX_PORTS, use ds->num_ports.
> (Matching the pattern of other net/dsa/tag_xxx.c files.)
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
