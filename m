From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Kernel oops in ip6t_LOG.c:ip6_nexthdr
Date: Thu, 26 Aug 2004 14:10:03 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040826141003.40229433.davem@redhat.com>
References: <20040826113538.GE15409@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040826113538.GE15409@suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2004 13:35:39 +0200
Olaf Kirch <okir@suse.de> wrote:

> hdrptr is a u_int8_t **. What you really want to do here is
> look at (*hdrptr)[1], but what the expression does is look at
> *(hdrptr[1]). Unfortunately, hdrptr[1] is usually random garbage.

Good catch, patch applied (to 2.4.x too).

Thanks Olaf.
