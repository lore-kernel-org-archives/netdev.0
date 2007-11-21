From: Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Thu, 22 Nov 2007 00:00:44 +1100
Message-ID: <47442BFC.8090008@hotmail.com>
References: <20071120.040546.222294375.davem@davemloft.net>
Reply-To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	   Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	   David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071120.040546.222294375.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

David Miller wrote:
> Shaddy I attach a hack patch that you can use which should get
> rid of the warnings.

It hasn't seemed to. I patched the source (confirming the patched lines 
are in), compiled, installed and rebooted to effect the changes. My 
zd1211rw modules timestamp indicates that I have an updated module:

$ ls -l /lib/modules/2.6.22/kernel/drivers/net/wireless/zd1211rw/zd1211rw.ko
-rw-r--r-- 1 root root 84536 2007-11-21 23:18 
/lib/modules/2.6.22/kernel/drivers/net/wireless/zd1211rw/zd1211rw.ko

lsmod confirms the module is loaded. After activating the interface 
(without configuring it yet):

$ ifconfig eth2 up

I start getting the messages over and over on the console:

Kernel unaligned access at TPC[100ee624] do_rx+0x394/0x5ec [zd1211rw]
Kernel unaligned access at TPC[100ee62c] do_rx+0x39c/0x5ec [zd1211rw]
Kernel unaligned access at TPC[100ee638] do_rx+0x3a8/0x5ec [zd1211rw]

Sorry that this has not been successful this time, but thanks for your 
help. I will be trying to follow-up on some of the other questions put 
to me.

Regards,
Shaddy
