From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.32-rc1] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Wed, 30 Sep 2009 17:39:23 -0700
Message-ID: <20090930173923.4520716a@s6510>
References: <alpine.LRH.2.00.0909301432410.8073@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Chris Wright <chrisw@sous-sol.org>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	pv-drivers <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755299AbZJAAjW@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0909301432410.8073@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Sep 2009 14:34:57 -0700 (PDT)
Shreyas Bhatewara <sbhatewara@vmware.com> wrote:

Note: your patch was linewrapped again

> +
> +
> +static void
> +vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
> +{
> +	struct net_device *netdev = adapter->netdev;
> +
> +	netdev->features = NETIF_F_SG |
> +		NETIF_F_HW_CSUM |
> +		NETIF_F_HW_VLAN_TX |
> +		NETIF_F_HW_VLAN_RX |
> +		NETIF_F_HW_VLAN_FILTER |
> +		NETIF_F_TSO |
> +		NETIF_F_TSO6;
> +
> +	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6");
> +
> +	adapter->rxcsum = true;
> +	adapter->jumbo_frame = true;
> +
> +	if (!disable_lro) {
> +		adapter->lro = true;
> +		printk(" lro");
> +	}

Why not use NETIF_F_LRO and ethtool to control LRO support?
