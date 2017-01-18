From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 7/7] IPVTAP: IP-VLAN based tap driver
Date: Wed, 18 Jan 2017 16:28:42 -0500 (EST)
Message-ID: <20170118.162842.2116473511473193362.davem@davemloft.net>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
        <1484697786-50323-8-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484697786-50323-8-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Tue, 17 Jan 2017 16:03:06 -0800

> +static void ipvtap_count_tx_dropped(struct tap_dev *tap)
> +{
> +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);
 ...
> +static void ipvtap_count_rx_dropped(struct tap_dev *tap)
> +{
> +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);
 ...
> +static void ipvtap_update_features(struct tap_dev *tap,
> +				   netdev_features_t features)
> +{
> +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);

More unnecessary casts, please remove.
