From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 3657] New: downed interfaces acting as
 aliases
Date: Thu, 28 Oct 2004 23:45:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028234502.203b42c3.davem@davemloft.net>
References: <20041028234649.2d4ed3b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mbm@alt.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041028234649.2d4ed3b8.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


People complain about this all the time, yet it is expected
and intentional behavior.

Just because you "down" the interface does not mean that
addresses assigned to that interface are no longer assosciated
with the host system.

If you wish the machine not to respond to any of the interface's
addresses, you must explicitly delete them from the interface
address list.
