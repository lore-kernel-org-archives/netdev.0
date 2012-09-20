From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Thu, 20 Sep 2012 09:31:53 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1209200931400.8409@stinky-local.trash.net>
References: <1347357081.3928.32.camel@localhost>   <20120912213627.GJ14750@breakpoint.cc>
 <20120914120750.GA5764@1984>   <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
  <1348058791.2761.94.camel@localhost>  <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
 <1348126142.2761.172.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348126142.2761.172.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2012, Jesper Dangaard Brouer wrote:

> On Thu, 2012-09-20 at 08:57 +0200, Patrick McHardy wrote:
>> On Wed, 19 Sep 2012, Jesper Dangaard Brouer wrote:
>>
>>> On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
>>>> On Fri, 14 Sep 2012, Pablo Neira Ayuso wrote:
>>>>
>>> [...cut...]
>>>>>> Patrick, any other idea?
>>>>>
>>> [...cut...]
> [... (hair)cut(?)...]
>
>>> No it does not work :-(
>>
>> Ok I think I understand the problem now, we're invoking the NAT cleanup
>> callback twice with clean->hash = true, once for each direction of the
>> conntrack.
>>
>> Does this patch fix the problem?
>
> Yes, it fixes the problem :-)
>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Great, thanks for testing.
