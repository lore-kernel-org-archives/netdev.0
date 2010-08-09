From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: i386 allmodconfig, current mainline
Date: Mon, 9 Aug 2010 16:48:37 -0700
Message-ID: <20100809164837.b0c34ef1.randy.dunlap@oracle.com>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	Phillip Lougher <phillip@lougher.demon.co.uk>,
	Faisal Latif <faisal.latif@intel.com>,
	Chien Tung <chien.tin.tung@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Samuel Ortiz <samuel.ortiz@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, x86@kernel.org,
	linux-rdma@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Aug 2010 16:43:46 -0700 Andrew Morton wrote:

> 
> Guys.  What's goin' on out there?
> 
> 
> drivers/power/olpc_battery.c:387: error: unknown field 'owner' specified in initializer
> drivers/power/olpc_battery.c:387: warning: initialization from incompatible pointer type
> make[2]: *** [drivers/power/olpc_battery.o] Error 1
> make[1]: *** [drivers/power] Error 2

David Woodhouse fixed this one today.


> fs/squashfs/xattr.c:37: warning: 'squashfs_xattr_handler' declared inline after being called
> fs/squashfs/xattr.c:37: warning: previous declaration of 'squashfs_xattr_handler' was here

I see this one on one system (with gcc 4.1.2) but not on f11 with gcc 4.4.1,
although it should be OK to "fix" it.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
