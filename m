From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 29 Nov 2013 15:13:03 +0100
Message-ID: <5298A0EF.70401@redhat.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com> <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab3K2ONN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 09:13:13 -0500
In-Reply-To: <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2013 06:31 PM, Eric Dumazet wrote:
> On Thu, 2013-11-28 at 12:57 +0100, Michal Sekletar wrote:
>
>> +enum {
>> +	BPF_ANC_FLAG_PROTOCOL         = (1 << 0),
>> +	BPF_ANC_FLAG_PKTTYPE          =	(1 << 1),
>> +	BPF_ANC_FLAG_IFINDEX          = (1 << 2),
>> +	BPF_ANC_FLAG_NLATTR           = (1 << 3),
>> +	BPF_ANC_FLAG_NLATTR_NEST      = (1 << 4),
>> +	BPF_ANC_FLAG_MARK             = (1 << 5),
>> +	BPF_ANC_FLAG_QUEUE            = (1 << 6),
>> +	BPF_ANC_FLAG_HATYPE           = (1 << 7),
>> +	BPF_ANC_FLAG_RXHASH           = (1 << 8),
>> +	BPF_ANC_FLAG_CPU              = (1 << 9),
>> +	BPF_ANC_FLAG_ALU_XOR_X        = (1 << 10),
>> +	BPF_ANC_FLAG_SECCOMP_LD_W     = (1 << 11),
>> +	BPF_ANC_FLAG_VLAN_TAG         = (1 << 12),
>> +	BPF_ANC_FLAG_VLAN_TAG_PRESENT = (1 << 13),
>> +	BPF_ANC_FLAG_PAY_OFFSET       = (1 << 14),
>> +};
>> +
>
> Why spending 15 bits (out of 32), for all these extensions ?
>
> It seems a single one should be enough.
>
> I do not think we will ever remove one of these extension.

Agreed, this will just cripple of us adding other extensions in
terms of uapi. I assume there won't be so much more extensions,
but it's of course hard to predict the future. ;-)
