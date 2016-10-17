From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 12:49:54 -0400 (EDT)
Message-ID: <20161017.124954.360760874377344385.davem@davemloft.net>
References: <20161008020434.9691-1-jarod@redhat.com>
        <20161008020434.9691-3-jarod@redhat.com>
        <20161017172006.4d549daa@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: kubakici@wp.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017172006.4d549daa@jkicinski-Precision-T1700>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Kicinski <kubakici@wp.pl>
Date: Mon, 17 Oct 2016 17:20:06 +0100

> Please correct me if I'm wrong but it seems like we are now limiting
> _all_ ethernet drivers to ETH_DATA_LEN in net-next.

No, because the driver can increase the netdev->max_mtu value as needed.
