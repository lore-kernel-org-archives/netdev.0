From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [5/6]: Dynamic neigh hash table growth
Date: Fri, 24 Sep 2004 13:26:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924132636.195d4035.davem@davemloft.net>
References: <20040923225127.10b0ef68.davem@davemloft.net>
	<OF75C0DF94.8BDAC480-ON88256F19.006C04FD-88256F19.006EF59D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF75C0DF94.8BDAC480-ON88256F19.006C04FD-88256F19.006EF59D@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 13:11:58 -0700
Krishna Kumar <kumarkr@us.ibm.com> wrote:

> In neigh_hash_grow(), next need not be set to NULL.

I thought the compiler would warn, but aparently it
doesn't, so I'll remove the assignment, thanks.

Perhaps an older version of gcc, which has poorer flow
analysis, will warn though... we'll see.
