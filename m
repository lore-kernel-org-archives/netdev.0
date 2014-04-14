From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tuntap: add flow control to support back pressure
Date: Sun, 13 Apr 2014 21:40:04 -0400 (EDT)
Message-ID: <20140413.214004.1087903132047842986.davem@davemloft.net>
References: <5347487B.4040608@adjacentlink.com>
	<20140413141745.GB17839@redhat.com>
	<534B3A33.9090401@adjacentlink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Brian.Adamson@nrl.navy.mil,
	jgiovatto@adjacentlink.com
To: sgalgano@adjacentlink.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534B3A33.9090401@adjacentlink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Galgano <sgalgano@adjacentlink.com>
Date: Sun, 13 Apr 2014 21:30:27 -0400

> Added optional per queue flow control support using IFF_FLOW_CONTROL. When the IFF_FLOW_CONTROL TUNSETIFF flag is specified it will set a per queue flag to indicate that the queue should be stopped using netif_tx_stop_queue(), rather than discarding frames once full. After reading a frame from the respective stopped queue, a netif_tx_wake_queue() is issued to signal resource availability.
> 
> The per queue TUN_FLOW_CONTROL flag is stored in struct tun_file. This provides the flexibility to enable flow control on all, none or some queues when using IFF_MULTI_QUEUE. When not using IFF_MULTI_QUEUE, IFF_FLOW_CONTROL will apply to the single queue. No changes were made to the default drop frame policy.
> 
> This change adds support for back pressure use cases.
> 
> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
> Tested-by: Joseph Giovatto <jgiovatto@djacentlink.com>
> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>

Please format your commit messages to ~80 columns of text.

It won't be automatically formatted by GIT and in fact it looks ugly
with all the wrapping in text based tools.
