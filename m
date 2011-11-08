From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v2 PATCH 1/2] NETFILTER module xt_hmark new target
	for HASH based fw
Date: Tue, 8 Nov 2011 16:12:27 +0100 (CET)
Message-ID: <b328f1j.5274a2398142147da04eb5e915d63283@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>On Tue, Nov 08, 2011 at 12:29:53AM +0100, Hans Schillstrom wrote:
>> >We prefer skb_header_pointer instead. If conntrack is enabled, we can
>> >benefit from defragmention. 
>> 
>> In  our case conntrack will not be there
>
>Yes, but if conntrack is there, we benefit from fragment reassembly if
>you use skb_header_pointer.
>
>> >Please, replace all pskb_may_pull by skb_header_pointer in this code.
>> >
>> >We can assume that the IP header is linear (not fragmented).
>> 
>> I ran in to this issue in IPv6 testing so I got a little bit "paranoid".
>> Are you sure that the embedded IP and L4 header in the ICMP msg also is unfragmented.  
>> Is this true for both IPv6 & IPv4 ?
>
>No sorry. I was refering to normal IP header in one packet.
>
>> From what I remember  when I was testing IPv6  icmp and digged into the original header (on a 2.6.32 kernel)  
>> pskb_may_pull was needed.
>
>Yes, it is indeed needed.
>
>> [snip]

[snip]


>
>Welcome, let's see if we can get this into 3.3 since we cannot make it
>for 3.2.
>
>BTW, do you have some number of this running with and without
>conntrack? It would be interesting to have.

I didn't save them,  but I can make a new benchmark later on.

Regards
Hans




