From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: [BK PATCHES] 2.6.x experimental net driver updates
Date: Thu, 18 Dec 2003 02:31:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218013145.GG25717@fs.tum.de>
References: <3FDEA6FA.4010906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux.nics@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FDEA6FA.4010906@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

I got the following compile error when trying to compile e100 statically 
into a kernel using gcc 2.95:

<--  snip  -->

...
  CC      drivers/net/e100.o
drivers/net/e100.c:170: parse error before `int'
drivers/net/e100.c:170: warning: type defaults to `int' in declaration 
of `module_param'
drivers/net/e100.c:170: warning: function declaration isn't a prototype
drivers/net/e100.c:170: warning: data definition has no type or storage 
class
make[2]: *** [drivers/net/e100.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
