From: Vladimir <vlists@veus.hr>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through
 an OpenBSD firewall]
Date: Tue, 14 Sep 2004 15:39:37 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41476519.9010606@veus.hr>
References: <41475BEA.2030803@us.ibm.com>	<41475E1E.7010200@veus.hr> <20040914141917.52cfa62e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com, netdev@oss.sgi.com
In-Reply-To: <20040914141917.52cfa62e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>OpenBSD packet filter is busted, and the maintainer of
>it claims this is not a bug.
>
>That changes in 2.6.6 didn't "break" things, it enabled a
>feature in TCP that OpenBSD stateless TCP connection tracking
>cannot handle, and old TCP feature in fact, window scaling.
>
>See here for more info:
>
>http://lwn.net/Articles/92727/
>
Thanks. We were able to fix our firewall so things work properly now. 
The problem is that this is "insidious" since it is not immediately 
apparent what the problem is especially since it tends to work with all 
other OSes except Linux with 2.6.6+.

I will note this on the bug I submitted and close it.

Thanks a lot,

Vladimir Vuksan
