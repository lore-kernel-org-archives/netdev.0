From: "David S. Miller" <davem@davemloft.net>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 12:50:14 -0700
Message-ID: <20050405125014.1ce46c66.davem@davemloft.net>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
	<20050405123438.28f02423.davem@davemloft.net>
	<Pine.LNX.4.58.0504051238390.14264@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.58.0504051238390.14264@server.graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005 12:47:09 -0700 (PDT)
Christoph Lameter <christoph@lameter.com> wrote:

> Correct that applies in general. But what could go wrong if the atomic_dec
> is separated from the atomic_read in this specific location?
> 
> I fail to see what the point of having a single instance of
> atomic_dec_and_test for __refcnt is. In particular since the upper layers
> guarantee that dst_destroy is not called multiple times for the same dst
> entry.

If this is true, what performance improvement could you possibly be
seeing from this change?

I know you are making this change for performance reasons, yet you
aren't mentioning any details about this.  That information is
part of what we need to know to judge this change.

I've very hesistant to undo atomic operation memory barriers, after
all of the weird problems we had in the neighbour cache.
