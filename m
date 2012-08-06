From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 17:39:52 -0400
Message-ID: <502039A8.7080807@gmail.com>
References: <87mx27rig7.fsf@xmission.com> <50201928.2030802@gmail.com> <874noflrzd.fsf@xmission.com> <20120806.134737.1358773847818872075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jan.ariyasu@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jan.ariyasu@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120806.134737.1358773847818872075.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2012 04:47 PM, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 06 Aug 2012 12:50:46 -0700
>
>> Vlad Yasevich <vyasevich@gmail.com> writes:
>>
>>
>>> Hi Eric
>>>
>>> Associations are looked up by ports, but then verifyed by addresses.
>>> Also, associations belong to sockets and simply validating the socket
>>> namespace should be sufficient.
>>
>> True.  Your set of patches isn't quite as likely to malfunction as it
>> looked at first glance.  It requires address reuse which happens accross
>> namespaces but not too frequently.
>>
>> As for validating the socket namespace I agree that is the fix and my
>> patchset winds up doing it.
>
> FWIW I much prefer Eric's patch set, it was so significantly easier to
> read and validate than Jan's.
>

Yes, but Eric's patch set is missing a very significant piece which is 
per-net sctp tunables/globals.  I think adding that piece in will 
introduce some of the complexities of Jan's patch.

Also, I noticed that Eric went the route of placing sctp netns into 
struct net, but Jan used a generic pointer.  Which one should be used? 
Is there some guidance?

-vlad
