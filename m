From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] list_for_each net/
Date: Wed, 3 Sep 2003 20:14:55 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030903201455.44200973.davem@redhat.com>
References: <20030903082202.GB13662@mail.sternwelten.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@osdl.org, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, marcel@holtmann.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: maximilian attems <janitor@sternwelten.at>
In-Reply-To: <20030903082202.GB13662@mail.sternwelten.at>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 10:22:02 +0200
maximilian attems <janitor@sternwelten.at> wrote:

> again pure cosmetical changes!!


I applied everything except for the ip6_fib.c part, there is
no way we should be using the list_head macros for objects
which are not list_heads.
