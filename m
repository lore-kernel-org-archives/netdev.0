From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add printk for bonding module packets_per_slave
 parameter
Date: Tue, 13 Jun 2017 11:34:11 -0400 (EDT)
Message-ID: <20170613.113411.506760268959654820.davem@davemloft.net>
References: <20170613134246.6407-1-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.j.dilmore@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613134246.6407-1-michael.j.dilmore@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Dilmore <michael.j.dilmore@gmail.com>
Date: Tue, 13 Jun 2017 14:42:46 +0100

> The packets per slave parameter used by round robin mode does not have a printk debug
> message in its set function in bond_options.c. Adding such a function would aid debugging
> of round-robin mode and allow the user to more easily verify that the parameter has been
> set correctly. I should add that I'm motivated by my own experience here - it's not
> obvious from output of tools such as wireshark and ifstat that the parameter is working
> correctly, and with the differences in bonding configuration across different distributions,
> it would have been comforting to see this output.
> 
> Signed-off-by: Michael Dilmore <michael.j.dilmore@gmail.com>
> 
> cc: Veaceslav Falico <vfalico@gmail.com>,Andy Gospodarek <andy@greyhouse.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org

You can verify things by simplying reading the value back.

If every parameter emitted a kernel log message, it would be
unreadable.

I'm not applying this, sorry.
