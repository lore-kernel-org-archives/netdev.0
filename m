From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Wed, 21 Jan 2015 14:14:05 -0800
Message-ID: <CAEP_g=_B5xTcfONUP4PTw91PdJKx_cN_+Qdd4F6300aXVyzLZg@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
 <CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
 <CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
 <CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
 <CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
 <CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
 <CAEP_g=-3GXJfawPb4jevkZhqmzTttsO1Rv_2J6GwpG=PR_a-0g@mail.gmail.com> <CA+mtBx9B5aS9Jv6tpUJpmBkvQFnUqjcxcgTjbBHee8K0f1C9KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:41558 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751702AbbAUWO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 17:14:26 -0500
Received: by mail-qg0-f49.google.com with SMTP id i50so13048473qgf.8
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 14:14:26 -0800 (PST)
In-Reply-To: <CA+mtBx9B5aS9Jv6tpUJpmBkvQFnUqjcxcgTjbBHee8K0f1C9KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 1:54 PM, Tom Herbert <therbert@google.com> wrote:
> On Wed, Jan 21, 2015 at 12:35 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Wed, Jan 21, 2015 at 11:45 AM, Tom Herbert <therbert@google.com> wrote:
>>>> I used bare metal intel servers. All VXLAN tests were done using linux
>>>> kernel device without any VMs. All STT tests are done using OVS bridge
>>>> and STT port.
>>>>
>>> So right off the bat you're running the baseline differently than the
>>> target. Anyway, I cannot replicate your numbers for VXLAN, I see much
>>> better performance and this with pretty old servers and dumb NICs. I
>>> suspect you might not have GSO/GRO properly enabled, but instead of
>>> trying to debug your setup, I'd rather restate my request that you
>>> provide a network interface to STT so we can do our own fair
>>> comparison.
>>
>> If I had to guess, I suspect the difference is that UDP RSS wasn't
>> enabled, since it doesn't come that way out of the box. Regardless,
>> you can clearly see a significant difference in single core
>> performance and CPU consumption.
>>
> I'm not going to try to draw conclusions from data which is obviously
> biased and incomplete. If you want to move forward on this, then just
> provide network interface for STT so we can independently run our own
> comparisons against other encapsulations like we've been doing all
> along.

You have the source code, so you are totally free to run whatever
tests you like to draw your own conclusions. Personally, I find a more
than doubling of performance in the environments that I have seen
compelling. Your mileage may vary.
