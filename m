From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Mon, 4 Apr 2005 22:37:44 -0700
Message-ID: <20050404223744.1f04c130.davem@davemloft.net>
References: <20050405133336.0247.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050405133336.0247.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Apr 2005 13:35:02 +0800
Wang Jian <lark@linux.net.cn> wrote:

> https://lists.netfilter.org/pipermail/netfilter-devel/2005-March/018762.html
> 
> I chose 509 for FW_FILTER_HSIZE. If you feel it is waste of memory, then
> 251 is good too.

Please us a power of two, the "%" is expensive on some cpus.
