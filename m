From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev()
 helper function
Date: Fri, 15 Nov 2013 06:26:05 +0100
Message-ID: <20131115052605.GA12440@lion.mk-sys.cz>
References: <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
 <5284E637.5060805@gmail.com>
 <20131114155756.GA4161@lion.mk-sys.cz>
 <20131114.170358.941846928393883945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lion.mk-sys.cz ([213.168.178.121]:46239 "EHLO lion.mk-sys.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755037Ab3KOF0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 00:26:07 -0500
Content-Disposition: inline
In-Reply-To: <20131114.170358.941846928393883945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 05:03:58PM -0500, David Miller wrote:
> >> On 11/14/2013 09:00 AM, Michal Kubecek wrote:
> >> >+#if IS_ENABLED(CONFIG_MACVLAN)
> >> >+static inline struct net_device *
> >> >+macvlan_dev_real_dev(const struct net_device *dev)
> >> >+{
> >> >+	struct macvlan_dev *macvlan = netdev_priv(dev);
> >> >+
> >> >+	return macvlan->lowerdev;
> >> >+}
> >> >+#else
> >> >+static inline struct net_device *
> >> >+macvlan_dev_real_dev(const struct net_device *dev)
> >> >+{
> >> >+	return NULL;
> >> >+}
> >> >+#endif
> >> >+
> 
> At least for the time being use BUG(), to be consistent with the same
> way how VLAN handles this situation.

OK, v3 sent.

Michal Kubecek
