From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700 Device
 Driver into the Linux Kernel
Date: Tue, 20 Aug 2013 13:58:22 -0700
Message-ID: <1377032302.2016.75.camel@joe-AO722>
References: <201308201841116403992@163.com>
	 <20130820204606.GB26241@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: liujunliang_ljl <liujunliang_ljl@163.com>, gregkh <gregkh@suse.de>,
	sunhecheng <sunhecheng@vip.126.com>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130820204606.GB26241@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-20 at 22:46 +0200, Francois Romieu wrote:
> liujunliang_ljl <liujunliang_ljl@163.com> :

> > +	if (i >= SR_SHARE_TIMEOUT) {
> > +		netdev_err(dev->net, "%s read timed out!", phy ? "phy" : "eeprom");

netdev_<level>, like almost all other printk
messages needs a terminating "\n" newline to
avoid any possible message interleaving by other
printks.

> > +	if (!is_valid_ether_addr(addr->sa_data)) {
> > +		dev_err(&net->dev, "not setting invalid mac address %pM\n",
> > +								addr->sa_data);
> 
> 		dev_err(&net->dev, "not setting invalid mac address %pM\n",
> 			addr->sa_data);

prefer netdev_<level> to dev_<level> where possible.
