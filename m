From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] fix bonding neighbour setup handling
Date: Mon, 05 Aug 2013 15:25:03 -0700 (PDT)
Message-ID: <20130805.152503.1956742286847859646.davem@davemloft.net>
References: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
	<20130802.154539.237539535236462726.davem@davemloft.net>
	<51FFAD54.7090501@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, ebiederm@xmission.com, joe@perches.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3HEWZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 18:25:06 -0400
In-Reply-To: <51FFAD54.7090501@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon, 05 Aug 2013 15:49:08 +0200

> Since the cat is out of the bag about this bug, as Vaeceslav discovered it
> independently and wasn't aware that there's a CVE number pending because it
> poses a security threat since the dereferenced first_slave pointer is
> taken from the struct vlan_dev_priv's ingress_priority map array which is
> user-controllable and any memory address can be dereferenced in that way,
> and taking after that first_slave->dev->netdev_ops and calling a function
> from the ops is making it even easier. Of course for that to happen the
> user must have CAP_NET_ADMIN.
> I've tested these patches and they apply cleanly on -net as well, so please
> queue them for -net and stable.

This is why I absolutely detest closed work on bugs, and prefer
everything be discussed and implemented openly here on this list,
without exceptions, and regardless of perceived "severity" of the bug.

Applied to net and queued up for -stable, thanks.
