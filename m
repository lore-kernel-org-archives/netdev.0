From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 11:04:58 +0100
Message-ID: <49C0C74A.1090709@trash.net>
References: <49C078B6.4020603@trash.net> <87tz5r17ac.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87tz5r17ac.fsf@basil.nowhere.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Patrick McHardy <kaber@trash.net> writes:
>   
>> The userspace frontend is probably even more different to iptables than
>> the kernel.
>>     
>
> Are there plans to implement the existing iptables/ipchains/ipfw user
> interfaces on top of nftables?
>   

I've thought about a "skin" in userspace to parse the iptables syntax
and convert it to the new syntax. But the kernel won't have a compatibility
interface and I'm not sure yet whether userspace will also be able to output
iptables syntax. ipchains etc. definitely not.

