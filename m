From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: 05 Apr 2005 06:25:34 -0400
Message-ID: <1112696733.1088.33.camel@jzny.localdomain>
References: <20050405133336.0247.LARK@linux.net.cn>
	 <20050404223744.1f04c130.davem@davemloft.net>
	 <20050405140342.024A.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050405140342.024A.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wang,

I read that thread and i am a little confused. What is this change
supposed to improve?

cheers,
jamal

On Tue, 2005-04-05 at 02:05, Wang Jian wrote:
> Hi David S. Miller,
> 
> New patch attached. Hashsize is 256, the same as old one.
> 
> 
> On Mon, 4 Apr 2005 22:37:44 -0700, "David S. Miller" <davem@davemloft.net> wrote:
> 
> > On Tue, 05 Apr 2005 13:35:02 +0800
> > Wang Jian <lark@linux.net.cn> wrote:
> > 
> > > https://lists.netfilter.org/pipermail/netfilter-devel/2005-March/018762.html
> > > 
> > > I chose 509 for FW_FILTER_HSIZE. If you feel it is waste of memory, then
> > > 251 is good too.
> > 
> > Please us a power of two, the "%" is expensive on some cpus.
> 
> 
