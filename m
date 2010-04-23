From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 13:06:45 +0200
Message-ID: <4BD17F45.3030802@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>	 <1271948029.7895.5707.camel@edumazet-laptop>	 <20100422155123.GA2524@linux.vnet.ibm.com>	 <1271952128.7895.5851.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>	 <1271970199.7895.6482.camel@edumazet-laptop>  <4BD17CAA.4090708@trash.net> <1272020717.7895.7974.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, paulmck@linux.vnet.ibm.com,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272020717.7895.7974.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le vendredi 23 avril 2010 =E0 12:55 +0200, Patrick McHardy a =E9crit =
:
>> Eric Dumazet wrote:
>>> OK but a lookup last a fraction of a micro second, unless interrupt=
ed by
>>> hard irq.
>>>
>>> Probability of a change during a lookup should be very very small.
>>>
>>> Note that the scenario for a restart is :
>>>
>>> The lookup go through the chain.
>>> While it is examining one object, this object is deleted.
>>> The object is re-allocated by another cpu and inserted to a new cha=
in.
>> I think another scenario that seems a bit more likely would be
>> that a new entry is added to the chain after it was fully searched.
>> Perhaps we could continue searching at the last position if the
>> last entry is not a nulls entry to improve this.
>=20
> But the last entry is always a nulls entry, what do you mean exactly =
?
>=20
> When an unsert (of a fresh object, not a reused one) is done, this
> doesnt affect lookups in any way, since its done at the head of list.

Right, I missed that :)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
