From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 5 Apr 2005 12:38:27 +0200
Message-ID: <20050405103827.GL26731@postel.suug.ch>
References: <20050405133336.0247.LARK@linux.net.cn> <20050404223744.1f04c130.davem@davemloft.net> <20050405140342.024A.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050405140342.024A.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050405140342.024A.LARK@linux.net.cn> 2005-04-05 14:05
> New patch attached. Hashsize is 256, the same as old one.

Do you have any numbers that could prove that this change
actually improves the hash distribution and thus the overall
lookup performance?

The most often used and thus most important range of mark
values is definitely 0..255. I did not look into jhash
but the risk of collisions definitely increases with this
change which affects about 90% of the users of fw which
could benefit from a collision free hashtable so far.

I would appreciate if you could provide some numbers proving
both the need and actual improvement of this change since
fwmark is one of the most often used classifiers.

Cheers
