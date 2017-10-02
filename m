From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v3 02/19] thunderbolt: Remove __packed from ICM message
 structures
Date: Mon, 02 Oct 2017 14:45:52 +0300
Message-ID: <1506944752.16112.224.camel@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
         <20171002103846.64602-3-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Mika Westerberg <mika.westerberg@linux.intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-3-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-02 at 13:38 +0300, Mika Westerberg wrote:
> These messages are all 32-byte aligned and they should be packed 

Obviously 32-bit.

Other than that,

Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

> without
> the __packed attribute just fine. It also allows compiler to generate
> better code on some architectures.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> Reviewed-by: Michael Jamet <michael.jamet@intel.com>
> Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
> ---
>  drivers/thunderbolt/tb_msgs.h | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/thunderbolt/tb_msgs.h
> b/drivers/thunderbolt/tb_msgs.h
> index de6441e4a060..f3adf58a40ce 100644
> --- a/drivers/thunderbolt/tb_msgs.h
> +++ b/drivers/thunderbolt/tb_msgs.h
> @@ -130,7 +130,7 @@ struct icm_pkg_header {
>  	u8 flags;
>  	u8 packet_id;
>  	u8 total_packets;
> -} __packed;
> +};
>  
>  #define ICM_FLAGS_ERROR			BIT(0)
>  #define ICM_FLAGS_NO_KEY		BIT(1)
> @@ -139,20 +139,20 @@ struct icm_pkg_header {
>  
>  struct icm_pkg_driver_ready {
>  	struct icm_pkg_header hdr;
> -} __packed;
> +};
>  
>  struct icm_pkg_driver_ready_response {
>  	struct icm_pkg_header hdr;
>  	u8 romver;
>  	u8 ramver;
>  	u16 security_level;
> -} __packed;
> +};
>  
>  /* Falcon Ridge & Alpine Ridge common messages */
>  
>  struct icm_fr_pkg_get_topology {
>  	struct icm_pkg_header hdr;
> -} __packed;
> +};
>  
>  #define ICM_GET_TOPOLOGY_PACKETS	14
>  
> @@ -167,7 +167,7 @@ struct icm_fr_pkg_get_topology_response {
>  	u32 reserved[2];
>  	u32 ports[16];
>  	u32 port_hop_info[16];
> -} __packed;
> +};
>  
>  #define ICM_SWITCH_USED			BIT(0)
>  #define ICM_SWITCH_UPSTREAM_PORT_MASK	GENMASK(7, 1)
> @@ -184,7 +184,7 @@ struct icm_fr_event_device_connected {
>  	u8 connection_id;
>  	u16 link_info;
>  	u32 ep_name[55];
> -} __packed;
> +};
>  
>  #define ICM_LINK_INFO_LINK_MASK		0x7
>  #define ICM_LINK_INFO_DEPTH_SHIFT	4
> @@ -197,13 +197,13 @@ struct icm_fr_pkg_approve_device {
>  	u8 connection_key;
>  	u8 connection_id;
>  	u16 reserved;
> -} __packed;
> +};
>  
>  struct icm_fr_event_device_disconnected {
>  	struct icm_pkg_header hdr;
>  	u16 reserved;
>  	u16 link_info;
> -} __packed;
> +};
>  
>  struct icm_fr_pkg_add_device_key {
>  	struct icm_pkg_header hdr;
> @@ -212,7 +212,7 @@ struct icm_fr_pkg_add_device_key {
>  	u8 connection_id;
>  	u16 reserved;
>  	u32 key[8];
> -} __packed;
> +};
>  
>  struct icm_fr_pkg_add_device_key_response {
>  	struct icm_pkg_header hdr;
> @@ -220,7 +220,7 @@ struct icm_fr_pkg_add_device_key_response {
>  	u8 connection_key;
>  	u8 connection_id;
>  	u16 reserved;
> -} __packed;
> +};
>  
>  struct icm_fr_pkg_challenge_device {
>  	struct icm_pkg_header hdr;
> @@ -229,7 +229,7 @@ struct icm_fr_pkg_challenge_device {
>  	u8 connection_id;
>  	u16 reserved;
>  	u32 challenge[8];
> -} __packed;
> +};
>  
>  struct icm_fr_pkg_challenge_device_response {
>  	struct icm_pkg_header hdr;
> @@ -239,7 +239,7 @@ struct icm_fr_pkg_challenge_device_response {
>  	u16 reserved;
>  	u32 challenge[8];
>  	u32 response[8];
> -} __packed;
> +};
>  
>  /* Alpine Ridge only messages */
>  
> @@ -247,7 +247,7 @@ struct icm_ar_pkg_get_route {
>  	struct icm_pkg_header hdr;
>  	u16 reserved;
>  	u16 link_info;
> -} __packed;
> +};
>  
>  struct icm_ar_pkg_get_route_response {
>  	struct icm_pkg_header hdr;
> @@ -255,6 +255,6 @@ struct icm_ar_pkg_get_route_response {
>  	u16 link_info;
>  	u32 route_hi;
>  	u32 route_lo;
> -} __packed;
> +};
>  
>  #endif

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
