From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Wed, 6 Apr 2005 15:45:02 +0200
Message-ID: <20050406134502.GP26731@postel.suug.ch>
References: <20050405213023.0256.LARK@linux.net.cn> <1112717495.1076.22.camel@jzny.localdomain> <20050406143842.026B.LARK@linux.net.cn> <20050406123036.GO26731@postel.suug.ch> <1112794459.1096.61.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Jian <lark@linux.net.cn>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112794459.1096.61.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112794459.1096.61.camel@jzny.localdomain> 2005-04-06 09:34
> On Wed, 2005-04-06 at 08:30, Thomas Graf wrote:
> 
> > Let the user specify one of the hash tables via a new TLV:
> >  - default: & 0xFF
> >  - ((mark & mask) >> shift) & 0xFF
> >  - jenkins for 16, 32, and 64 bits
> >  - FNV for 16, 32, and 64 bits
> 
> When does the user specify this? i would think you need to set it once
> only per bootup. After that it will be quiet complex to reset. It could
> be done but sounds complex and unnecessary. i.e it may be a boot or
> module parameter more than it is a netlink controlled value, no?

I'm not 100% sure about this yet but I think during fw_change so
we can have different hashes for different qdiscs filter chains.
