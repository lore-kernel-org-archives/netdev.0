From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] how to submit fixes for i40e/i40evf?
Date: Mon, 28 Aug 2017 10:00:54 -0700
Message-ID: <CAKgT0UfjBqma9=71DMVJkxfHGMB15CmPw3uVFaj=-N6gqygE6Q@mail.gmail.com>
References: <20170825225215.35fc6b59@elisabeth> <CAKgT0UcLAw0958zJ4o9V9Vyamvd1mBQX1+9GAaZw-hZubMqXnw@mail.gmail.com>
 <20170826002852.751d5f07@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:33570 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdH1RA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:00:56 -0400
Received: by mail-qt0-f177.google.com with SMTP id e2so4873814qta.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:00:56 -0700 (PDT)
In-Reply-To: <20170826002852.751d5f07@elisabeth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 3:28 PM, Stefano Brivio <sbrivio@redhat.com> wrote:
> On Fri, 25 Aug 2017 15:10:08 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Fri, Aug 25, 2017 at 1:52 PM, Stefano Brivio <sbrivio@redhat.com> wrote:
>>
>> [...]
>>
>> > Once patches reach Intel's patchwork, will they need to wait for some
>> > kind of periodically scheduled pull request process?
>>
>> Once in the patchwork they go through testing and after they have
>> passed testing Jeff will try to push them to Dave.
>
> Ok, the whole part above is clear, thanks a lot for clarifying.
>
>> > I don't know if a process is actually defined at this level of detail,
>> > but still I feel it's wrong that an obvious fix for a potential crash is
>> > waiting in some sort of limbo for 10 days now. Sure, worse things
>> > happen in the world, but I can't understand what this patch is waiting
>> > for.
>>
>> Well in the case of your patch it was rejected as it didn't apply to
>> Jeff's tree
>
> It actually did when I posted it.
>
>> and conflicted with Jacob Keller's patch. He submitted a v2 on Tuesday
>> which has only been applied for a few days. Once it receives a
>> "Tested-by:"
>
> Which, if I understood correctly, only comes after some internal testing
> process, right?
>
>> it will be ready for submission assuming it passes testing.
>
> Now that patch is again in a v2 pull request for net-next, without the
> changes I suggested for the commit message. And the same exact code
> changes were around for two weeks. IMHO there's room for improvement,
> so to speak.
>
>> I hope that helps to clarify things.
>
> It did to some extent, and thanks again for that.

One other thing I forgot that adds to the confusion is that you will
probably want to base you patch on the dev-queue branch of those
trees, not the master branch. The master branch is what Jeff submits
to Dave if I am not mistaken, while dev-queue is the location for the
ongoing development.

- Alex
