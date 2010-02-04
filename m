From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 04 Feb 2010 15:31:22 +0100
Message-ID: <4B6ADA3A.7040201@trash.net>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-02-04 13:58, Thomas Woerner wrote:
> 
>> Hello,
>>
>> I just fell over network interface definitions in kernel and
>> netfilter/iptables.
>>
>> Interfaces names in the kernel have few limits: Only spaces and slashes are not
>> allowed, but everything else, even Ctrl characters are.
>>
>> In iptables, there are other limits: Colon, exclamation mark and asterisk are
>> not allowed. The plus is treated special for matching. But what will be matched
>> if the interface starts with or contains a plus?
>>
>> iptables allows to use interfaces containing spaces and slashes. iptables-save
>> is not escaping interface names. The interface "+" will be treated as no
>> interface limit at all and will be dropped, therefore all interfaces match.
>>
>> I think there should be some discussion about interface names and limits in
>> kernel and netfilter/iptables.
>>
>> What do you think?
> 
> I think we should cc netdev for a start.

I don't think there is a reason for this limitation in iptables,
so why not simply remove it?
