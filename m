From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] TCP burst control
Date: Tue, 6 Jul 2004 16:04:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706160447.3c2efffa.davem@redhat.com>
References: <20040706155858.11b368e6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rhee@ncsu.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040706155858.11b368e6@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 15:58:58 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When using advanced congestion control it is possible for TCP to decide that
> it has a large window to fill with data right away. The problem is that if TCP
> creates long bursts, it becomes unfriendly to other flows and is more likely
> to overrun intermediate queues.
> 
> This patch limits the amount of data in flight. It came from BICTCP 1.1 but it 
> has been generalized to all TCP congestion algorithms. It has had some testing,
> but needs to be more widely tested.

Both the New Reno and Westwood+ algorithms implement rate-halving to
solve this problem.

Why can't BICTCP use that instead of this special burst control hack?
