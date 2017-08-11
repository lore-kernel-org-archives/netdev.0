From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Fri, 11 Aug 2017 07:37:22 -0700
Message-ID: <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com> <20170811123405.GY773745@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Amine Kherbouche <amine.kherbouche@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:35166 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752967AbdHKOhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 10:37:23 -0400
Received: by mail-vk0-f50.google.com with SMTP id d124so13958070vkf.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 07:37:23 -0700 (PDT)
In-Reply-To: <20170811123405.GY773745@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 5:34 AM, David Lamparter <equinox@diac24.net> wrote:
> On Thu, Aug 10, 2017 at 10:28:36PM +0200, Amine Kherbouche wrote:
>> Mpls handler allows creation/deletion of mpls routes without using
>> rtnetlink. When an incoming mpls packet matches this route, the saved
>> function handler is called.
>
> Since I originally authored this patch, I have come to believe that it
> might be unneccessarily complicated.  It is unlikely that a lot of
> different "handlers" will exist here;  the only things I can think of
> are VPLS support and BIER-MPLS multicast replication.  I'm not saying
> it's a bad idea, but, well, this was in the README that I gave to 6WIND
> with this code:
>
> ...

yes, I would also prefer just exporting the functions  and calling
them directly instead of adding a
handler layer. We can move to that later if it becomes necessary.
