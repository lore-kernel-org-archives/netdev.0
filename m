From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Hang in downing interface with IPv6 PRIVACY
Date: Sat, 8 Nov 2003 22:30:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108223049.36651f8d.davem@redhat.com>
References: <20031106115935.0cd56745.davem@redhat.com>
	<Pine.LNX.4.44.0311071034230.1107-100000@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0311071034230.1107-100000@linux.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Nov 2003 11:01:41 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> While using PRIVACY extensions, I sometimes get a hang when I remove the
> interface. But I can reproduce this every time using the test script at
> the end of the mail (hang depends on the order of address deletion).
 ...
> The bug is in ipv6_del_addr() where if a temp address is being deleted
 ...
> Also, the code at the top of the routine is unnecessary, the same is being
> done when the address is found a little later in that routine.

Looks great, applied.

Thanks.
