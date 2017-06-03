From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] virtio_net: lower limit on buffer size
Date: Sat, 3 Jun 2017 23:17:30 +0300
Message-ID: <aafb81af-54f2-06b0-3b5c-2713bc28184b@cogentembedded.com>
References: <1496361148-4603-1-git-send-email-mst@redhat.com>
 <3dd90d56-7110-bb9e-0b7f-4c8a8003a57f@cogentembedded.com>
 <20170602202536.GA24411@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        linux-kernel@vger.kernel.org,
        Mikulas Patocka <mpatocka@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36695 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdFCURe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 16:17:34 -0400
Received: by mail-lf0-f54.google.com with SMTP id o83so8369936lff.3
        for <netdev@vger.kernel.org>; Sat, 03 Jun 2017 13:17:33 -0700 (PDT)
In-Reply-To: <20170602202536.GA24411@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2017 11:25 PM, J. Bruce Fields wrote:

>>> commit d85b758f72b0 "virtio_net: fix support for small rings"
>>
>>    Commit d85b758f72b0 ("virtio_net: fix support for small rings")
>>
>>> was supposed to increase the buffer size for small rings
>>> but had an unintentional side effect of decreasing
>>> it for large rings. This seems to break some setups -
>>> it's not yet clear why, but increasing buffer size
>>> back to what it was before helps.
>>>
>>> Fixes: d85b758f72b0 "virtio_net: fix support for small rings"
>>
>> Fixes: d85b758f72b0 ("virtio_net: fix support for small rings")
>
> I may be bikeshedding, but, personally I never do the parens--they're
> redundant given the quotes, and space is often tight.

    Just see Documetation/process/submitting-patches.rst.

MBR, Sergei
