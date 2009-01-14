From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 1/4] virtio_net: Allow setting the MAC address of the
 NIC
Date: Wed, 14 Jan 2009 10:15:06 +0000
Message-ID: <1231928106.4944.289.camel@localhost.localdomain>
References: <1231881796.9095.186.camel@bling>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231881796.9095.186.camel@bling>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:

Commit log explaining why we need this.

> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Mark McLoughlin <markmc@redhat.com>

> +	} else {
>  		random_ether_addr(dev->dev_addr);
> +		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> +				  dev->dev_addr, dev->addr_len);
> +	}

Please make sure you test this with a host which doesn't set a default
mac address, otherwise it's "untested buggy code" :-)

Cheers,
Mark.

