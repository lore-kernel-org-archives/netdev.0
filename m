From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 13:30:11 +0100
Message-ID: <490705D3.4040809@trash.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir> <20081028000044.GA16721@ioremap.net> <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com> <20081028104346.GA31146@ioremap.net> <4907008A.6050808@trash.net> <20081028122554.GA12945@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hamid jafarian <hamid.jafarian@gmail.com>,
	Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Harald Welte <laforge@gnumonks.org>,
	Eric Leblond <eric@inl.fr>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Amin Azez <azez@ufomechanic.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081028122554.GA12945@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Oct 28, 2008 at 01:07:38PM +0100, Patrick McHardy (kaber@trash.net) wrote:
>> I think these patches are a lost cause. Besides the fact that they
>> move things to the kernel instead of to userspace, they
> 
> What about part which replaces rules array with a list?
> That's the main part I was interested in though.

Thats also the part that breaks userspace compatibility and requires
to move a lot of userspace code to the kernel, at least in that
design. Its not possible to do this with iptables without breaking
userspace compability.

