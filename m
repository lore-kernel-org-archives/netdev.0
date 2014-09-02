From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Re: 3.16/3.16.1: Kernel Oops in nft_do_chain
Date: Tue, 02 Sep 2014 18:44:57 +0200
Message-ID: <5405F409.70107@c-s.fr>
References: <54059883.4060309@c-s.fr> <20140902104114.GA10805@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140902104114.GA10805@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 02/09/2014 12:41, Pablo Neira Ayuso a =E9crit :
> On Tue, Sep 02, 2014 at 12:14:27PM +0200, leroy christophe wrote:
>> Calling 'iptables-compat -L', first time nothing is listed on the sc=
reen.
>> Second try, it generates following Oops.
> I'm going to pass this patch to -stable asap:
>
> commit b88825de8545ad252c31543fef13cadf4de7a2bc
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Tue Aug 5 17:25:59 2014 +0200
>
>      netfilter: nf_tables: don't update chain with unset counters
>     =20
>      Fix possible replacement of the per-cpu chain counters by null
>      pointer when updating an existing chain in the commit path.
>     =20
>      Reported-by: Matteo Croce <technoboy85@gmail.com>
>      Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>
> I think it's the root cause for this problem.
Thanks, it does fix the Oops I had.

Christophe
