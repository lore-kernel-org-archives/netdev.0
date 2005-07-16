From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: TX handler changes (experimental)
Date: Sat, 16 Jul 2005 16:04:06 +0200
Message-ID: <42D913D6.5050902__29890.0668196895$1121523170$gmane$org@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Attached is a patch that modifies the tx interrupt handling of the 
nForce nic. It's part of the attempts to figure out what causes the nic 
hangs (see bug 4552).
The change is experimental: It affects all nForce versions. I've tested 
it on my nForce 250-Gb.

Please test it. And especially: If you experince a nic hang, please send 
me the debug output. That's the block starting with

<<
NETDEV WATCHDOG: eth1: transmit timed out
eth1: Got tx_timeout. irq: 00000000
eth1: Ring at  ...
<<

Thanks,
    Manfred
