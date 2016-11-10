From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 4/7] vxlan: improve vxlan route lookup checks.
Date: Wed, 9 Nov 2016 19:34:06 -0800
Message-ID: <CAOrHB_BwcJ0K3YcqPrVkKxFjWX9DFT1NjS3BbrcNtKQ_p_y44w@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-5-git-send-email-pshelar@ovn.org> <20161109174138.410b4385@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:36937 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbcKJDeM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:34:12 -0500
Received: from mfilter32-d.gandi.net (mfilter32-d.gandi.net [217.70.178.163])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 6BA6541C04C
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:34:09 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter32-d.gandi.net (mfilter32-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id HUWXB7EYZH5D for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 04:34:08 +0100 (CET)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id E23E541C08B
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:34:07 +0100 (CET)
Received: by mail-it0-f41.google.com with SMTP id e187so47009019itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 19:34:07 -0800 (PST)
In-Reply-To: <20161109174138.410b4385@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 8:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat,  5 Nov 2016 11:45:54 -0700, Pravin B Shelar wrote:
>> Move route sanity check to respective vxlan[4/6]_get_route functions.
>> This allows us to perform all sanity checks before caching the dst so
>> that we can avoid these checks on subsequent packets.
>> This give move accurate metadata information for packet from
>> fill_metadata_dst().
>
> The description is misleading, it applies only to one vxlan lwt use case
> (openvswitch). For other use cases, the patch has no effect.
>
Why it would not help in non-ovs vxlan egress path? It avoids checking
(if condition) for device loop.

> I found the current handling of route lookup results irritating, too.
> The reason I did not change this while doing vxlan cleanup some time
> ago was that I assumed we should not increase dev stats from
> vxlan_fill_metadata_dst. Isn't that so?
>

Thats right. I will fix it.
