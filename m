From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 5/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sun, 19 May 2013 11:36:17 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305191135380.4537@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305181905490.7518@fry.nucleusys.com> <20130518211041.GD26590@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130518211041.GD26590@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 May 2013, Francois Romieu wrote:

> Petko Manolov <petkan@nucleusys.com> :
> [...]
> > @@ -681,16 +681,15 @@ static int rtl8150_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
> >  }
> >  
> >  static const struct net_device_ops rtl8150_netdev_ops = {
> > -	.ndo_open		= rtl8150_open,
> > -	.ndo_stop		= rtl8150_close,
> > -	.ndo_do_ioctl		= rtl8150_ioctl,
> > -	.ndo_start_xmit		= rtl8150_start_xmit,
> > -	.ndo_tx_timeout		= rtl8150_tx_timeout,
> > -	.ndo_set_rx_mode	= rtl8150_set_multicast,
> > -	.ndo_set_mac_address	= rtl8150_set_mac_address,
> > -
> > -	.ndo_change_mtu		= eth_change_mtu,
> > -	.ndo_validate_addr	= eth_validate_addr,
> > +	.ndo_open = rtl8150_open,
> > +	.ndo_stop = rtl8150_close,
> > +	.ndo_do_ioctl = rtl8150_ioctl,
> > +	.ndo_start_xmit = rtl8150_start_xmit,
> > +	.ndo_tx_timeout = rtl8150_tx_timeout,
> > +	.ndo_set_rx_mode = rtl8150_set_multicast,
> > +	.ndo_set_mac_address = rtl8150_set_mac_address,
> > +	.ndo_change_mtu	= eth_change_mtu,
> > +	.ndo_validate_addr = eth_validate_addr,
> 
> This is wrong.

I am inclined to agree with you.
