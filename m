From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 18:16:36 +1000
Message-ID: <1117613796.26331.2479.camel@hole.melbourne.sgi.com>
References: <20050531.154847.63995530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050531.154847.63995530.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-06-01 at 08:48, David S. Miller wrote:
> So the idea is, if we can make all of the spinlocks BH locks we'll
> solve a whole bunch of problems:
> [...]
> 2) the driver will actually produce useful profiling data
>    via oprofile and friends since timer interrupts will run
>    even while holding the locks

That would be really, really nice.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
