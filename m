From: "hamid jafarian" <hamid.jafarian@gmail.com>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 16:27:04 +0330
Message-ID: <464293e60810280557p33eb6a2bsd21e1a238816c3a8@mail.gmail.com>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
	 <20081028000044.GA16721@ioremap.net>
	 <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com>
	 <20081028104346.GA31146@ioremap.net> <4907008A.6050808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Jan Engelhardt" <jengelh@medozas.de>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	"Harald Welte" <laforge@gnumonks.org>,
	"Eric Leblond" <eric@inl.fr>,
	"Jozsef Kadlecsik" <kadlec@blackhole.kfki.hu>,
	"Amin Azez" <azez@ufomechanic.net>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4907008A.6050808@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,
> I think these patches are a lost cause.
may be!!.. and also may not
>Besides the fact that they
> move things to the kernel instead of to userspace, they
just adding/removing.. beside huge efforts in the previous version in
copying/cloning this seems not to be bad effort..

> - break the existing interface
> - do not use netlink
i didn't change any function prototype at the user space, so i think
nothing is break (only the functions implementations at libiptc.c are
changed).. just between kernel and user (this is internal).. and just
for entries structure..
netlink is one of my ideas about this version and may implement..
> - are a drop-in replacement instead of incremental changes or a
>  completely new implementation
by this new idea, many things are changed and wrirten from scratch.. i
can continue its implementation to be completed.
> - fix only a very small part of the problems of the current
>  iptables design
beside your new ideas about nftables, this implementation also has
some new ideas:
about sets in  nftables: we can implement sets as classifier in this version
about registers in nftables: we can see matches as registers in this version
and about multiple targets: this version can use multiple targets..
>
> I've asked Hamid to post these patches to see if there were any
> useful incremental changes that would make sense to apply to
> iptables, but it seems to come down to moving userspace to kernel
> to support incremental changes.
not only user to kernel.. this limited to add/remove..
using classifiers as search engine, common framework for tables and
new semantics.. so on..


-- 
Hamid Jafarian (hm.t)
