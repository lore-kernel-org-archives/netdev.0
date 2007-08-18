From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Re: checksum of lsrr
Date: Sat, 18 Aug 2007 22:18:58 +0900 (JST)
Message-ID: <20070818.221858.74741723.chamas@h4.dion.ne.jp>
References: <20070704.222824.74749937.chamas@h4.dion.ne.jp>
	<20070723.003119.74728388.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm05mta.dion.ne.jp ([219.125.112.3]:4877 "HELO
	nm05omta053.dion.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750716AbXHRNTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 09:19:01 -0400
In-Reply-To: <20070723.003119.74728388.chamas@h4.dion.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello, I'm sorry I make a fuss.

Only FYI, one of my box has 3Com NIC

  00:0c.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 78)
       Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC Management NIC
       Flags: bus master, medium devsel, latency 32, IRQ 11
       I/O ports at b800 [size=128]
       Memory at df800000 (32-bit, non-prefetchable) [size=128]
       [virtual] Expansion ROM at 30000000 [disabled] [size=128K]
       Capabilities: <access denied>

I turned off hardware checksum, then it can connect using lsrr.

    Kernel command line: root=/dev/hdb2 ro 3c59x.hw_checksums=0

Thanks,
