From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 06/16] thunderbolt: Add support for XDomain
 discovery protocol
Date: Tue, 26 Sep 2017 21:35:17 -0700 (PDT)
Message-ID: <20170926.213517.1467163782062660869.davem@davemloft.net>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
        <20170925110738.68382-7-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        michael.jamet@intel.com, yehezkel.bernat@intel.com,
        amir.jer.levy@intel.com, Mario.Limonciello@dell.com,
        lukas@wunner.de, andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925110738.68382-7-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Mon, 25 Sep 2017 14:07:28 +0300

> +struct icm_fr_event_xdomain_connected {
> +	struct icm_pkg_header hdr;
> +	u16 reserved;
> +	u16 link_info;
> +	uuid_t remote_uuid;
> +	uuid_t local_uuid;
> +	u32 local_route_hi;
> +	u32 local_route_lo;
> +	u32 remote_route_hi;
> +	u32 remote_route_lo;
> +} __packed;
> +
> +struct icm_fr_event_xdomain_disconnected {
> +	struct icm_pkg_header hdr;
> +	u16 reserved;
> +	u16 link_info;
> +	uuid_t remote_uuid;
> +} __packed;
> +
>  struct icm_fr_pkg_add_device_key {
>  	struct icm_pkg_header hdr;
>  	uuid_t ep_uuid;

Again, __packed should be avoided unless absolutely necessary.

Thank you.
