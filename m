From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Wed, 3 Sep 2003 20:04:26 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030903200426.59d0af4a.davem@redhat.com>
References: <20030902143050.GC3398@conectiva.com.br>
	<200309022116.41697.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309022116.41697.bdschuym@pandora.be>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2003 21:16:41 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> On Tuesday 02 September 2003 16:30, Arnaldo Carvalho de Melo wrote:
> > The 1.786.1.54 changeset (i.e. the initial ipt_physdev.c one 8) created
> 
> Does this fix it?

You can't use this fix.  This header and structure are used by
userspace and "unsigned long" can be a different size in the
kernel than it is in user space.

Please, just remove the super-silly memcmp() optimization in
the ipt_physdev.c code.
