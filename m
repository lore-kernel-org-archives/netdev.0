From: =?UTF-8?Q?Michal_Seklet=C3=A1r?= <sekletar.m@gmail.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 5 Dec 2013 18:28:19 +0100
Message-ID: <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com>
	<1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<5298A0EF.70401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:64485 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933141Ab3LER2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 12:28:20 -0500
Received: by mail-ve0-f173.google.com with SMTP id oz11so14360883veb.32
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 09:28:19 -0800 (PST)
In-Reply-To: <5298A0EF.70401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 29, 2013 at 3:13 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 11/28/2013 06:31 PM, Eric Dumazet wrote:
>>
>> On Thu, 2013-11-28 at 12:57 +0100, Michal Sekletar wrote:
>>
>>> +enum {
>>> +       BPF_ANC_FLAG_PROTOCOL         = (1 << 0),
>>> +       BPF_ANC_FLAG_PKTTYPE          = (1 << 1),
>>> +       BPF_ANC_FLAG_IFINDEX          = (1 << 2),
>>> +       BPF_ANC_FLAG_NLATTR           = (1 << 3),
>>> +       BPF_ANC_FLAG_NLATTR_NEST      = (1 << 4),
>>> +       BPF_ANC_FLAG_MARK             = (1 << 5),
>>> +       BPF_ANC_FLAG_QUEUE            = (1 << 6),
>>> +       BPF_ANC_FLAG_HATYPE           = (1 << 7),
>>> +       BPF_ANC_FLAG_RXHASH           = (1 << 8),
>>> +       BPF_ANC_FLAG_CPU              = (1 << 9),
>>> +       BPF_ANC_FLAG_ALU_XOR_X        = (1 << 10),
>>> +       BPF_ANC_FLAG_SECCOMP_LD_W     = (1 << 11),
>>> +       BPF_ANC_FLAG_VLAN_TAG         = (1 << 12),
>>> +       BPF_ANC_FLAG_VLAN_TAG_PRESENT = (1 << 13),
>>> +       BPF_ANC_FLAG_PAY_OFFSET       = (1 << 14),
>>> +};
>>> +
>>
>>
>> Why spending 15 bits (out of 32), for all these extensions ?
>>
>> It seems a single one should be enough.
>>
>> I do not think we will ever remove one of these extension.
>
>
> Agreed, this will just cripple of us adding other extensions in
> terms of uapi. I assume there won't be so much more extensions,
> but it's of course hard to predict the future. ;-)
>

Not sure I follow. Can you please elaborate on the explanation. Please
bare with me this is my first kernel patch submission.

Thanks,

Michal

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
