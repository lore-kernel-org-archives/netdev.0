From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] NETFILTER: new ip_conntrack_sctp
Date: Sun, 1 Aug 2004 19:28:09 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040801192809.5ab29c25.davem@redhat.com>
References: <20040801230338.GE18758@sunbeam2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
        immidi_kiran@yahoo.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040801230338.GE18758@sunbeam2>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Mon, 2 Aug 2004 01:03:38 +0200
Harald Welte <laforge@netfilter.org> wrote:

> Incremental to all other patches so far

Not really.  Harald you really need to fixup your
diff scripts wrt. handling non-netfilter files.

Every diff you've sent me in this whole set against
linux/sysctl.h has rejected, including this one.
In this instance, none of the tcp-window-tracking
sysctls were in the sysctl.h file you diffed against.

I fixed this up by hand, so don't worry about this
instance.
