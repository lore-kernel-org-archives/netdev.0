From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Date: Fri, 04 May 2007 18:36:50 -0300
Message-ID: <463BA772.9070203@redhat.com>
References: <20070504102651.923946304@chello.nl> <1178292179.7997.12.camel@imap.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Daniel Walker <dwalker@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031708AbXEDVhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 17:37:33 -0400
In-Reply-To: <1178292179.7997.12.camel@imap.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Walker wrote:
> On Fri, 2007-05-04 at 12:26 +0200, Peter Zijlstra wrote:
>
>   
>> 1) introduce the memory reserve and make the SLAB allocator play nice with it.
>>    patches 01-10
>>
>> 2) add some needed infrastructure to the network code
>>    patches 11-13
>>
>> 3) implement the idea outlined above
>>    patches 14-20
>>
>> 4) teach the swap machinery to use generic address_spaces
>>    patches 21-24
>>
>> 5) implement swap over NFS using all the new stuff
>>    patches 25-31
>>
>> 6) implement swap over iSCSI
>>    patches 32-40
>>     
>
> This is kind of a lot of patches all at once .. Have you release any of
> these patch sets prior to this release ? 
>   

Yes, several times AFAIK.

- Arnaldo
