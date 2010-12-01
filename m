From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] bonding: clean up netpoll code
Date: Wed, 01 Dec 2010 16:26:47 +0800
Message-ID: <4CF606C7.6020606@redhat.com>
References: <20101201075043.5741.29172.sendpatchset@localhost.localdomain> <1291190612.2856.481.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291190612.2856.481.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/10 16:03, Eric Dumazet wrote:
> Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 02:45 -0500, Amerigo Wang a =
=C3=A9crit :
>> Against net-next-2.6.
>>
>> This patch unifies the netpoll code in bonding with netpoll code in =
bridge,
>> thanks to Herbert that code is much cleaner now.
>>
>> It also removes the flag IFF_IN_NETPOLL, we don't need it any more s=
ince
>> we have netpoll_tx_running() now.
>>
>> It passes my basic testings.
>
> Sorry this NETPOLL patch is frightening...
>
> Could you split it in several parts ?
>
> The removal of IFF_IN_NETPOLL deserves a patch on its own, its not a
> cleanup at all, if you ask me.
>

Is this necessary?
It is just replacing checking IFF_IN_NETPOLL with netpoll_tx_running(),
you might need to take a look at the bridge code.
