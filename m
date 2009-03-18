From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 11:17:01 +0100
Message-ID: <49C0CA1D.7020804@trash.net>
References: <49C078B6.4020603@trash.net> <87tz5r17ac.fsf@basil.nowhere.org> <49C0C74A.1090709@trash.net> <49C0C946.4090606@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C0C946.4090606@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan wrote:
> Patrick McHardy wrote:
>> Andi Kleen wrote:
>>> Are there plans to implement the existing iptables/ipchains/ipfw user
>>> interfaces on top of nftables?
>>>       
>>
>> I've thought about a "skin" in userspace to parse the iptables syntax
>> and convert it to the new syntax. But the kernel won't have a
>> compatibility
>> interface and I'm not sure yet whether userspace will also be able to
>> output
>> iptables syntax. ipchains etc. definitely not.
>>
>>   
> So, in that case if you are not going to provide a "skin" and that
> iptables will be removed eventually. wouldnt it break applications
> using iptables?
> Sorry for such a basic question, but just curious.

Something will have to be done for compatibility, the skin is
probably the easiest way. Compatibility on the kernel side would
get incredibly ugly, I prefer something in userspace with a longer
transition period.

But all of this is still quite some time away :)
