From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 0/7] sctp: network namespace support Part 2:
 per net tunables
Date: Thu, 09 Aug 2012 10:07:12 -0400
Message-ID: <5023C410.9030708@gmail.com>
References: <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <87ipcud3ld.fsf_-_@xmission.com> <20120808.232058.1128673474849407813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jan.ariyasu@hp.com, jan.ariyasu@gmail.com, nhorman@tuxdriver.com,
	tgraf@infradead.org, xi.wang@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120808.232058.1128673474849407813.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2012 02:20 AM, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 07 Aug 2012 10:17:02 -0700
>
>> Since I am motivated to get things done, and since there has been much
>> grumbling about my patches not implementing tunables, I have added
>> tunable support on top of my last patchset.
>>
>> I have performed basic testing on the these patches and nothing
>> appears amis.
>>
>> The sm statemachine is a major tease as it has all of these association
>> and endpoint pointers in the common set of function parameters that turn
>> out to be NULL at the most inconvinient times.  So I added to the common
>> parameter list a struct net pointer, that is never NULL.
>
> I like Eric's patch set and I'd like to apply it to net-next.
>
> Vlad?
>


I like these patches much more as well, but not done reviewing yet. 
I'll try to finish the review tonight

-vlad
