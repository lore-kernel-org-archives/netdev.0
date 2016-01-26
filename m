From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on
 inactive slaves
Date: Tue, 26 Jan 2016 13:21:00 -0800 (PST)
Message-ID: <20160126.132100.2226639620327251279.davem@davemloft.net>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
	<1453562589.1223.445.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160126211453.GQ59058@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	tom@herbertland.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160126211453.GQ59058@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Tue, 26 Jan 2016 16:14:53 -0500

> # ethtool -S bond0
> no stats available

ethtool -S is for device specific stats.

Some drivers use this facility to provide per-RX-queue and per-TX-queue
versions of the existing core netdev stats.
