From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 8/8] net: qualcomm: add QCA7000 UART driver
Date: Tue, 18 Oct 2016 14:30:25 -0400 (EDT)
Message-ID: <20161018.143025.284251297276702898.davem@davemloft.net>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
        <1476790054-27174-9-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, jslaby@suse.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933100AbcJRSa0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:30:26 -0400
In-Reply-To: <1476790054-27174-9-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 18 Oct 2016 13:27:34 +0200

> +void
> +qca_tty_receive(struct tty_struct *tty, const unsigned char *cp, char *fp,
> +		int count)
> +{
> +	struct qcauart *qca = tty->disc_data;
> +	struct net_device_stats *n_stats = &qca->net_dev->stats;
> +	int dropped = 0;

Please order local variable declarations from longest to shortest line.

> +netdev_tx_t
> +qcauart_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct qcauart *qca = netdev_priv(dev);
> +	struct net_device_stats *n_stats = &dev->stats;
> +	u8 *pos;
> +	u8 pad_len = 0;
> +	int written;

Likewise.
