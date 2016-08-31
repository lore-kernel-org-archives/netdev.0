From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 15:25:34 +0200
Message-ID: <20160831132534.GA15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 04:32:44PM -0400, Vivien Didelot wrote:
> Add SWITCHDEV_OBJ_ID_PORT_MDB support to the DSA layer.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  Documentation/networking/dsa/dsa.txt | 23 +++++++++++++++
>  include/net/dsa.h                    | 16 +++++++++++
>  net/dsa/slave.c                      | 55 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 94 insertions(+)
> 
> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
> index 44ed453..6db7bc8 100644
> --- a/Documentation/networking/dsa/dsa.txt
> +++ b/Documentation/networking/dsa/dsa.txt
> @@ -584,6 +584,29 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
>    function that the driver has to call for each MAC address known to be behind
>    the given port. A switchdev object is used to carry the VID and FDB info.
>  
> +- port_mdb_prepare: bridge layer function invoked when the bridge prepares the
> +  installation of a multicast group database entry.

Hi Vivien

Terminology question. This function is used to add a multicast MAC
address to the switch tables. I've always considered a multicast group
as an IP layer thing. But this documentation is also considering a
multicast group to be a layer 2 thing.

Does the bridge code use multicast group when referring to L2?

     Thanks
	Andrew
