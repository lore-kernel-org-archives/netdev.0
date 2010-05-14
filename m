From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from
 nf_conntrack_sip
Date: Fri, 14 May 2010 20:33:35 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005142032270.13800@obet.zrqbmnf.qr>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BED92AF.50704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-05-14 20:13, Patrick McHardy wrote:
>Jason Gunthorpe wrote:
>> At least the XEN net front driver always produces non linear skbs,
>> so the SIP module does nothing at all when used with that NIC.
>> 
>> Unconditionally linearize the skb..
>> 
>> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>> ---
>>  net/netfilter/nf_conntrack_sip.c |    9 +++------
>>  1 files changed, 3 insertions(+), 6 deletions(-)
>> 
>> Patrick/Jan, thanks.. This is what I wanted to do in the first place,
>> but I couldn't convince myself it was safe, as no other nf code does
>> this..
>
>Your patch is based on an old version, the current version also
>supports TCP. I'll commit this patch to my tree after some testing.

nf_defrag defragments the packets, but then they're still non-linear?
I'm clearly missing something, could somenoe elaborate?
