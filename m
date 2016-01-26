From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on inactive
 slaves
Date: Tue, 26 Jan 2016 16:36:54 -0500
Message-ID: <20160126213654.GT59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453562589.1223.445.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160126211453.GQ59058@redhat.com>
 <20160126.132100.2226639620327251279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	tom@herbertland.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160126.132100.2226639620327251279.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 01:21:00PM -0800, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Tue, 26 Jan 2016 16:14:53 -0500
> 
> > # ethtool -S bond0
> > no stats available
> 
> ethtool -S is for device specific stats.

Okay, good, that was what it looked like to me. Glad I'm not completely
lost here. :)

So this sort of output wouldn't belong there, it should show up in sysfs,
procfs, and be available to ip over netlink.

> Some drivers use this facility to provide per-RX-queue and per-TX-queue
> versions of the existing core netdev stats.

-- 
Jarod Wilson
jarod@redhat.com
