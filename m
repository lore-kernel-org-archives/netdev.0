From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 15:16:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020151601.41b6fcbd.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<1098278702.16002.7.camel@baruch.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <1098278702.16002.7.camel@baruch.hamilton.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 14:25:02 +0100
Baruch Even <baruch@ev-en.org> wrote:

> The web100 patch gives you that, but it's not part of the basic kernel.

You don't need web100 for this simple statistic, see "tcpi_retrans"
We also provide nearly all of the lost packet tracking stats in
the form of "tcpi_unacked", "tcpi_sacked", "tcpi_lost", and
"tcpi_fackets".

In fact, web100 duplicates a lot of functionality provided already
by tcp_diag :-)
