From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 3657] New: downed interfaces acting as aliases
Date: Fri, 29 Oct 2004 00:10:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4181ED02.1060501@candelatech.com>
References: <20041028234649.2d4ed3b8.akpm@osdl.org> <20041028234502.203b42c3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, mbm@alt.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041028234502.203b42c3.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> People complain about this all the time, yet it is expected
> and intentional behavior.
> 
> Just because you "down" the interface does not mean that
> addresses assigned to that interface are no longer assosciated
> with the host system.
> 
> If you wish the machine not to respond to any of the interface's
> addresses, you must explicitly delete them from the interface
> address list.

Why would you want this behaviour?  If it's configured down, it would
seem that the user is trying to tell the system not to use it :)

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
