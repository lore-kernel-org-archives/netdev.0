From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec performance
Date: Tue, 3 May 2005 02:55:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
 <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Miika Komu <miika@iki.fi>
In-Reply-To: <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 May 2005, Miika Komu wrote:
>> I compared TCP-over-NULL-ESP vs. plain-TCP throughput with "ttcp" tool and
>> obtained the following results:
>>
>> Plain-TCP:	11 megabytes/s
>> NULL-ESP:	2.5 megabytes/s
>>
> I browsed the archives also and found this one:
>
> http://oss.sgi.com/archives/netdev/2004-12/msg00801.html

null encryption uses a block size of 1, which causes inefficent handling
of the data. I'm unsure if some hack for this specific case is worth it
since its only meant for testing.

Regards
Patrick
