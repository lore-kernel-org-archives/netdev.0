From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 18:23:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916182335.359c419f.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<20030916140621.GE810@obroa-skai.de.gnumonks.org>
	<20030916151533.GA28380@home.tig-grr.com>
	<200309161757.50682.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy@home.tig-grr.com, laforge@netfilter.org, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309161757.50682.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2003 17:57:50 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> 2.4 hasn't got ipt_physdev

But recall that there are other netfilter modules doing this
"compare chars using cast to long" trick that need to be fixed
too.

Also, adding attributes to user exported structures would need
to be done _very_ carefully, as compilation when using such
gcc extensions will fail when the user uses '-ansi' on the
compiler command line.
