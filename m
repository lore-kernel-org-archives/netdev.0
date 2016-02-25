From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Thu, 25 Feb 2016 22:34:40 +0100
Message-ID: <56CF7370.7020100@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com> <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com> <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com> <56CDECE5.5040604@iogearbox.net> <56CEF242.5090908@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57104 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbcBYVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:34:44 -0500
In-Reply-To: <56CEF242.5090908@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2016 01:23 PM, Jamal Hadi Salim wrote:
> On 16-02-24 12:48 PM, Daniel Borkmann wrote:
>> On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:
[...]
>>> Drivers do set the hash. My use case is slightly different.
>>> I have a NIC which has an embedded cavium processor. This thing
>>> strips off the TLV and uses the hash to select the host MSI.
>>> Only thing we dont use at the moment is queue_mapping.
>>
>> Ok, but the example says ingress qdisc. ;) I presume the driver for the
>> NIC and the offloading parts are non-public? :/
>
> Well, it is not exactly mellanox or intel - but I am sure someone would
> be willing to sell that NIC.
>
>> So, without them, placing
>> this on ingress qdisc doesn't seem much useful wrt the skb hash example,
>> and most people only have the software part (for ingress I mean) available.
>
> Do you want me to take skbbhash out? I just want to get this set in then
> worry about adding and modifying.

Well, if the NIC driver and offloading parts for ife are not available
(or cannot be made available) in the upstream kernel tree, then you have
to assume that everyone else can _only_ use this with the existing tc
facilities in the kernel. And as such, the whole set needs to be evaluated,
I think this is nothing new. ;-)

That is why I asked for a "typical setup" and use-case earlier. And if
it doesn't have any obvious ones in upstream context without the missing
pieces, then the code might linger around unused by anyone. So taking out
these parts would be highly preferred (unless there's a _good_ reason not
to).

Thanks,
Daniel
