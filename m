From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Tue, 16 Sep 2014 13:35:30 -0700
Message-ID: <CA+mtBx_4czWNAPSD7a06OrDyWrgvULu69E0BMKW5-V-UZatB4A@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
	<CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
	<CAJ3xEMjUKRCOodKs0XF_8xc0WY6=1UH=5STmeLS-a0=ofnSA9w@mail.gmail.com>
	<CA+mtBx9d4wkcfmbPXm8m-Uz8K=_hjb3Q_a-0YNY4Yhz4cYoD5Q@mail.gmail.com>
	<CAJ3xEMhax-S1KneM-cpRS9r4yi==JwqaGtMYJ127Ka2tynhHMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:59023 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbaIPUfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:35:31 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so69044igc.13
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 13:35:30 -0700 (PDT)
In-Reply-To: <CAJ3xEMhax-S1KneM-cpRS9r4yi==JwqaGtMYJ127Ka2tynhHMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 1:04 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Sep 16, 2014 at 6:00 PM, Tom Herbert <therbert@google.com> wrote:
>> [...] Fortunately, we'll be able to code
>> around mosts of the limitations of deployed NICs that don't implement
>> generic mechanisms (with UDP RSS, checksum conversions,  remote
>> checksum offload) [...]
>
> So UDP RSS is a clear requirement and NICs have it by now.
>
> Re checksum conversions, I assume you mean the ability on the RX path
> to report CHECKSUM_COMPLETE on any sort of IP packet potentially
> having multiple encapsulations, right? how would you phrase (and
> model) the other way around, e.g what is the generic requirement on
> the TX path w.r.t checksum offload?
>
> And I wasn't sure what do you mean by remote checksum offload, can you clarify?
>
This is the part intend to solve TX checksum offload for encapsulation
for "dumb" devices. Unlike, checksum conversion, this one requires a
bit of protocol support so we need an extensible encapsulation header.

http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00

> Or.
