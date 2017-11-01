From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: lan9303: lan9303_rcv set
 skb->offload_fwd_mark
Date: Wed, 1 Nov 2017 13:03:54 +0100
Message-ID: <20171101120354.GA12680@lunn.ch>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
 <20171031144802.12686-4-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171031144802.12686-4-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> One exception: Because the ALR is set up to forward STP BPDUs only to CPU,
> the SW bridge should flood STP BPDUs if local STP is not enabled.
> This is archived by not setting skb->offload_fwd_mark on STP BPDUs.

Hi Egil

This bit is interesting. I had not thought about that.

I think we need a few more drivers to set offload_fwd_mark, and then
maybe try to consolidate it into the core. But it is too early now.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
