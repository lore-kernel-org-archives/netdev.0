From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: next-20120620 build error in netfilter
Date: Sat, 23 Jun 2012 02:20:35 +0200
Message-ID: <20120623002035.GB21360@1984>
References: <32596.1340212473@turing-police.cc.vt.edu>
 <20120620172801.GA9385@1984>
 <55558.1340217472@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: valdis.kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55558.1340217472@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 20, 2012 at 02:37:52PM -0400, valdis.kletnieks@vt.edu wrote:
> On Wed, 20 Jun 2012 19:28:01 +0200, Pablo Neira Ayuso said:
> > On Wed, Jun 20, 2012 at 01:14:33PM -0400, Valdis Kletnieks wrote:
> > > Today's linux-next fails to build with CONFIG_NF_NAT_NEEDED=y and CONFIG_NF_NAT=m
> > >
> > >   LD      init/built-in.o
> > > net/built-in.o:(.data+0x4408): undefined reference to `nf_nat_tcp_seq_adjust'
> > > make: *** [vmlinux] Error 1
> >
> > I guess you have NF_CT_NETLINK=y, right?
> 
> Yes.
> 
> Temporary workaround was setting NF_NAT=n (I don't use NAT, I just usually
> build all the netfilter modules as =m even if I don't use them, just to provide
> build coverage and trip over stuff like this).

Probably NF_CT_NETLINK=m is a better workaround.

Anyway, I've enqueued the following patch to fix this:

http://1984.lsi.us.es/git/nf-next/commit/?id=d584a61a931e6cbfef0dd811c4ae0250ec5987f4

So you can use your previous config.

Thanks.
