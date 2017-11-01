From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: lan9303: Transmit using ALR when
 unicast
Date: Wed, 1 Nov 2017 13:04:32 +0100
Message-ID: <20171101120432.GC12680@lunn.ch>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
 <20171031144802.12686-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171031144802.12686-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 03:48:00PM +0100, Egil Hjelmeland wrote:
> lan9303_xmit_use_arl() introduced in previous patch set is wrong.
> The chip flood broadcast and unknown multicast frames. The effect is that
> broadcasts and multicasts are duplicated on egress. It is not possible to
> configure the chip to direct unknown multicasts to CPU port only.
> 
> This means that only unicast frames can be transmitted using ALR lookup.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
