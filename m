From: "J.A. Magallon" <jamagallon@able.es>
Subject: Re: 2.6.1-mm4
Date: Sun, 18 Jan 2004 01:12:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118001217.GE3125@werewolf.able.es>
References: <20040115225948.6b994a48.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org> (from akpm@osdl.org on Fri, Jan 16, 2004 at 07:59:48 +0100)
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 01.16, Andrew Morton wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/
> 
> 

Net driver problem:

werewolf:/etc# modprobe --verbose 3c59x
insmod /lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko 
FATAL: Error inserting 3c59x (/lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko): Invalid argument

/var/messages:
Jan 18 01:03:00 werewolf kernel: 3c59x: falsely claims to have parameter rx_copybreak

Hardware:

00:12.0 Ethernet controller: 3Com Corporation 3c980-TX 10/100baseTX NIC [Python-T] (rev 78)
        Subsystem: 3Com Corporation: Unknown device 1000
        Flags: bus master, medium devsel, latency 32, IRQ 5
        I/O ports at ec00 [size=128]
        Memory at febfef80 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at feba0000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2

(if you answer from netdev, plz CC: me, I'm not subscribed. thanks)

TIA

-- 
J.A. Magallon <jamagallon()able!es>     \                 Software is like sex:
werewolf!able!es                         \           It's better when it's free
Mandrake Linux release 10.0 (Cooker) for i586
Linux 2.6.1-jam4 (gcc 3.3.2 (Mandrake Linux 10.0 3.3.2-4mdk))
