From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] firewire: net: really fix maximum possible MTU
Date: Sat, 29 Oct 2016 23:01:04 -0400 (EDT)
Message-ID: <20161029.230104.141605741908542764.davem@davemloft.net>
References: <20161023162903.4166a35d@kant>
        <20161023163056.6bc38610@kant>
        <20161029221658.03942ff6@kant>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
        jarod@redhat.com, linux-kernel@vger.kernel.org
To: stefanr@s5r6.in-berlin.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161029221658.03942ff6@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Sat, 29 Oct 2016 22:16:58 +0200

> The maximum unicast datagram size /without/ link fragmentation is
> 4096 - 4 = 4092 (max IEEE 1394 async payload size at >= S800 bus speed,
> minus unfragmented encapssulation header).  Max broadcast datagram size
> without fragmentation is 8 bytes less than that (due to GASP header).
> 
> The maximum datagram size /with/ link fragmentation is 0xfff = 4095
> for unicast and broadcast.  This is because the RFC 2734 fragment
> encapsulation header field for datagram size is only 12 bits wide.
> 
> Fixes: 5d48f00d836a('firewire: net: fix maximum possible MTU')
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

Applied, thanks.
