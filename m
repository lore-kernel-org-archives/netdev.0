From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 15:10:00 +0200
Message-ID: <48C12FA8.5080608@trash.net>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain> <48C11918.8020508@trash.net> <48C11DF5.9040207@netfilter.org> <48C12526.90501@trash.net> <alpine.LNX.1.10.0809050908160.17569@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0809050908160.17569@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Friday 2008-09-05 08:25, Patrick McHardy wrote:
>>>> I hope so :) A different possiblity suggest by Pablo some time ago
>>>> would be to mark untracked packets in skb->nfctinfo and not
>>>> attach a conntrack at all.
>>> Indeed, I remember that :). I left that patch of the table time ago [1].
>>> There's a nf_reset call missing as Patrick said at that time. I can
>>> recover it if you like the idea.
>> I think that would be a good idea.
> 
> Would that work? Right now, a ct==NULL indicates the 'INVALID' state,
> and overloading it with 'UNTRACKED' does not seem nice.

ct == NULL would indicate either untracked or invalid.
For the cases where it makes a difference, ctinfo has
to be checked additionally.

