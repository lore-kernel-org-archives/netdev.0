From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 18:16:03 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030916181603.366b7c06.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<200309132159.37834.bdschuym@pandora.be>
	<20030915155903.12a3f95d.davem@redhat.com>
	<200309160805.08171.bdschuym@pandora.be>
	<20030915230259.79f5a545.davem@redhat.com>
	<1063703910.5948.85.camel@henrik.marasystems.com>
	<20030916140918.GF810@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hno@marasystems.com, bdschuym@pandora.be, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030916140918.GF810@obroa-skai.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2003 16:09:18 +0200
Harald Welte <laforge@netfilter.org> wrote:

> On Tue, Sep 16, 2003 at 11:18:34AM +0200, Henrik Nordstrom wrote:
> > tis 2003-09-16 klockan 08.02 skrev David S. Miller:
> > 
> > unfortunately iptables does not allow such differences between userspace
> > and kernel representation..
> 
> yes. yes. yes.  The whole 'kernel internal data structure exported to
> userspace' is a fundamental design flaw of iptables.  There's nothing we
> can do about it, we'll have to live with it :(

Why can't you change this?

Just because the user gives the kernel the data in one format, this
does not at all prevent the actual iptables kernel implementation from
using some other structure to store the data.  You just have to translate
things on the way in and out, that's all.
