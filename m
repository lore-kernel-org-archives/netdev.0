From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through an
 OpenBSD firewall]
Date: Tue, 14 Sep 2004 14:19:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914141917.52cfa62e.davem@davemloft.net>
References: <41475BEA.2030803@us.ibm.com>
	<41475E1E.7010200@veus.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir <vlists@veus.hr>
In-Reply-To: <41475E1E.7010200@veus.hr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 15:09:50 -0600
Vladimir <vlists@veus.hr> wrote:

> > Is the OpenBSD mangling the packet in any way?
> 
> It is certainly possible but everything works fine with all other OSes 
> and kernels 2.6.5 and below which leads me to believe something was 
> changed in 2.6.6 that broke it.
> 
> Are you able to reproduce it ?

OpenBSD packet filter is busted, and the maintainer of
it claims this is not a bug.

That changes in 2.6.6 didn't "break" things, it enabled a
feature in TCP that OpenBSD stateless TCP connection tracking
cannot handle, and old TCP feature in fact, window scaling.

See here for more info:

http://lwn.net/Articles/92727/
