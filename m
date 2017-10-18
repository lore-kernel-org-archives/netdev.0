From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Wed, 18 Oct 2017 17:31:40 +0200
Message-ID: <59E773DC.5090206@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net> <20171018132526.GC1302522@devbig577.frc2.facebook.com> <59E75F4F.7070706@iogearbox.net> <59E7639A.4060604@iogearbox.net> <CAADnVQLk2gu1j3PXjDCfF1hh09-5Ak_8Xd5hq48xTAJNR0Xb=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Richard Weinberger <richard@nod.at>, sp3485@columbia.edu,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Dennis Zhou <dennisszhou@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43856 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdJRPbq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:31:46 -0400
In-Reply-To: <CAADnVQLk2gu1j3PXjDCfF1hh09-5Ak_8Xd5hq48xTAJNR0Xb=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2017 05:28 PM, Alexei Starovoitov wrote:
> On Wed, Oct 18, 2017 at 7:22 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>> Higher prio imo would be to make the allocation itself faster
>> though, I remember we talked about this back in May wrt hashtable,
>> but I kind of lost track whether there was an update on this in
>> the mean time. ;-)
>
> new percpu allocator by Dennis fixed those issues. It's in 4.14

Ah, perfect!
