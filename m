From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Mon, 8 Sep 2003 19:14:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908191400.5ef59ab6.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<20030903200426.59d0af4a.davem@redhat.com>
	<20030905153152.GA3623@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Sep 2003 17:31:52 +0200
Harald Welte <laforge@netfilter.org> wrote:

> The problem is that it is _not_ a simple reimplementation of memcmp(),
> but a mask-compare.

Ok.  It still should be fixed by not using the "unsigned long *"
cast-and-op tricks...
