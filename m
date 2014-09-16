From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Tue, 16 Sep 2014 23:04:30 +0300
Message-ID: <CAJ3xEMhax-S1KneM-cpRS9r4yi==JwqaGtMYJ127Ka2tynhHMw@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
	<CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
	<CAJ3xEMjUKRCOodKs0XF_8xc0WY6=1UH=5STmeLS-a0=ofnSA9w@mail.gmail.com>
	<CA+mtBx9d4wkcfmbPXm8m-Uz8K=_hjb3Q_a-0YNY4Yhz4cYoD5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:46310 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbaIPUEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:04:31 -0400
Received: by mail-ob0-f180.google.com with SMTP id wp4so314397obc.39
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 13:04:30 -0700 (PDT)
In-Reply-To: <CA+mtBx9d4wkcfmbPXm8m-Uz8K=_hjb3Q_a-0YNY4Yhz4cYoD5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 6:00 PM, Tom Herbert <therbert@google.com> wrote:
> [...] Fortunately, we'll be able to code
> around mosts of the limitations of deployed NICs that don't implement
> generic mechanisms (with UDP RSS, checksum conversions,  remote
> checksum offload) [...]

So UDP RSS is a clear requirement and NICs have it by now.

Re checksum conversions, I assume you mean the ability on the RX path
to report CHECKSUM_COMPLETE on any sort of IP packet potentially
having multiple encapsulations, right? how would you phrase (and
model) the other way around, e.g what is the generic requirement on
the TX path w.r.t checksum offload?

And I wasn't sure what do you mean by remote checksum offload, can you clarify?

Or.
