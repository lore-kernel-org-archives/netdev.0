From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How to accelerate tcp retransmition
Date: Tue, 24 Jan 2012 09:57:24 -0800
Message-ID: <4F1EF104.1040107@hp.com>
References: <CAC=NXX3jdCAjmwTjQ-d43DWb-617a33nMcWb_UvBUyB_q7VZTQ@mail.gmail.com> <CAC=NXX2NLsChhuY5_Bv3HJ4fvnq7XpM7UksPS80uaZgGsJnfVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: leno soff <lnxuff@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAC=NXX2NLsChhuY5_Bv3HJ4fvnq7XpM7UksPS80uaZgGsJnfVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/24/2012 06:09 AM, leno soff wrote:
> On Tue, Jan 24, 2012 at 4:58 PM, leno soff<lnxuff@gmail.com>  wrote:
>> Hello everyone,
>>    I have a lot of client, say C1, C2, .. Cn, which route packets to
>> my servers through router R. But R will drop 70% - 90% _ non-SYN _
>> packets from clients to Server.

I think you should address that first - why does the router drop 70 to 
905 of the non-SYN segments it receives.  At first blush that sounds 
like a classic case of massive over-subscription, and any attempt to 
accelerate the retransmissions seems destined to trigger congestive 
collapse.

As a side issue, if the router is dropping 70 to 90% of the non-SYN 
segments, why is it not also dropping 70 to 90% of the SYN segments?

Also, I'm reasonably confident that an actual keepalive probe would not 
(or at least should not?) be considered in the three duplicate ACK 
heuristic.

rick jones
