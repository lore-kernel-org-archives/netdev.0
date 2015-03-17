From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 17 Mar 2015 17:37:21 -0400 (EDT)
Message-ID: <20150317.173721.927219759019408047.davem@davemloft.net>
References: <20150317.152324.744727347577991569.davem@redhat.com>
	<BY2PR0301MB0711AB7E8E0432AD57E29908A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
	<BY2PR0301MB07111A928395465732E9F4F0A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, olaf@aepfle.de, netdev@vger.kernel.org,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB07111A928395465732E9F4F0A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KY Srinivasan <kys@microsoft.com>
Date: Tue, 17 Mar 2015 20:07:10 +0000

> I pulled down the net-next tree and the issue is with the first patch:
> 0001-Drivers-hv-vmbus-Export-the-vmbus_sendpacket_pagebuf.patch
> 
> The net-next tree is not current with Greg's tree and this patch is on code that
> is in Greg's tree. This patch merely exports an API that is already in Greg's tree.
> Greg wanted me to take this patch through your tree since the only user
> of this functionality is the network driver. Any suggestions on how I should 
> proceed here.
> 
> The second patch:
> 0002-hyperv-Support-batched-notification.patch
> 
> applies cleanly to your tree.

Don't create cross-tree dependencies like this.

I'm not pulling in Greg's tree to get a dependency like this.

And if I don't, I can't apply patch #2 because it will fail to
build.
