From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 2/2] net: dsa: lan9303: Learn addresses on
 CPU port when bridged
Date: Thu, 26 Oct 2017 16:38:23 +0200
Message-ID: <20171026143823.GO20299@lunn.ch>
References: <20171026090049.1647-1-privat@egil-hjelmeland.no>
 <20171026090049.1647-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171026090049.1647-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2017 at 11:00:49AM +0200, Egil Hjelmeland wrote:
> When CPU transmit directly to port using tag, the LAN9303 does not
> learn MAC addresses received on the CPU port into the ALR.
> ALR learning is performed only when transmitting using ALR lookup.
> 
> Solution:
> If the two external ports are bridged and the packet is not STP BPDU,
> then use ALR lookup to allow ALR learning on CPU port.
> Otherwise transmit directly to port with STP state override.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
