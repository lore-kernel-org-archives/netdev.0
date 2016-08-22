From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/2] ipv6: fixup RTF_* flags when restoring RTPROT_RA
 route from rtnetlink
Date: Mon, 22 Aug 2016 14:06:50 +0300
Message-ID: <81e12d33-0c32-58ae-8320-bd79cb13c8d6@cogentembedded.com>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
 <cover.1471622715.git.ayourtch@gmail.com>
 <55219c8da12705fefa36ee5853b899ee88f730fb.1471622715.git.ayourtch@gmail.com>
 <689653c8-bc05-705c-04d6-ff7570b28dd0@cogentembedded.com>
 <alpine.DEB.2.20.1608221300280.31586@ayourtch-u1604b2>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Yourtchenko <ayourtch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33048 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbcHVLHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:07:41 -0400
Received: by mail-lf0-f54.google.com with SMTP id b199so75021115lfe.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:06:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.20.1608221300280.31586@ayourtch-u1604b2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/22/2016 2:04 PM, Andrew Yourtchenko wrote:

>>> Fix the flags for RA-derived routes that were saved
>>> via "ip -6 route save" and and subsequently restored via
>>> "ip -6 route restore", allowing the incoming router advertisements
>>> to update them, rather than complain about inability to do so.
>>>
>>> Upon the restore of RA-derived saved routes, set the RTF_ADDRCONF
>>> to indicate that the source of the route was originally
>>> a router advertisement, and set the RTF_DEFAULT or RTF_ROUTEINFO
>>> flag depending on prefix length. This can be considered a
>>> sister change of f0396f60d7c165018c9b203fb9b89fb224835578, in
>>
>>    It's enough to specify 12 digits but you also need to specify the commit
>> summary enclosed in ("").
>
> Is just the first line of "ipv6: fix RTPROT_RA markup of RA routes
> w/nexthops" enough, or do I need to include the additional two

    Summary means the patch subject (and the first line of the commit log).

> paragraphs that follow ? (and can I keep the full hash rather than
> truncate down to 12 digits?)

    Yes.

>>> the other direction.
>>>
>>> Signed-off-by: Andrew Yourtchenko <ayourtch@gmail.com>
[...]

MBR, Sergei
