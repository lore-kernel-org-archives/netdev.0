From: Jiri Gaisler <jiri@gaisler.com>
Subject: Re: Clean kernel patch for LEON/SPARC
Date: Wed, 20 Aug 2003 19:31:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F43B061.3010805@gaisler.com>
References: <3F43551A.1060901@gaisler.com> <20030820123311.A6511@devserv.devel.redhat.com>
Reply-To: jiri@gaisler.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20030820123311.A6511@devserv.devel.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pete Zaitcev wrote:

 > The serial has to go to Russell King, but I can look, too.
 > Best of all is to cc to linux-kernel.
 >
 > About Ethernet, it probably ought to go to netdev@oss.sgi.com.
 > I am not quite sure.
 >

I have made three patches that makes up the leon/sparc port
for linux-2.5.75:


* linux-2.5.75_kernel_only.diff  - leon support in kernel

* linux-2.5.75_open_eth.diff     - opencores ethernet driver

* linux-2.5.75_leon_uart.diff    - leon uart driver


The total size is about 150 Kbyte, so to avoid a large email
the patches can be downloaded from:

http://www.gaisler.com/patches.html


I don't have Russell King's email address, maybe you could
forward this mail to him?

> Did you guys figure out the cause of the severe problem
> with cache corruption?

Yes, this was a virtual address aliasing problem. Leon2 has
virtual caches but the MMU has no aliasing detection, so we
are forced to flush the cache on each task switch. Our next
processor (leon3) will have to switch to either physical caches
or have some form of aliasing detection ...

Regards, Jiri.
-- 
-------------------------------------------------------------------------
Gaisler Research, Stora Nygatan 13, 41108 Goteborg, Sweden, +46-31802405
fax: +46-31802407 email: info@gaisler.com, home page: www.gaisler.com
-------------------------------------------------------------------------
