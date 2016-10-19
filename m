From: Amir Vadai <amirva@gmail.com>
Subject: Re: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb specified.
Date: Wed, 19 Oct 2016 11:44:10 +0300
Message-ID: <CAPcc5Pg=vy67dMcr4U6DFwZu5UgSWyV6c662cv9XR-QXKfUVXw@mail.gmail.com>
References: <1476736212-21238-1-git-send-email-e@erig.me> <CAJ3xEMiR3EODEV5aQ9cQG=7YZtVfFkbpHn79_j+s8H7XQ5F0rA@mail.gmail.com>
Reply-To: amir@vadai.me
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Garver <e@erig.me>, David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33318 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942417AbcJSPaQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:30:16 -0400
Received: by mail-lf0-f65.google.com with SMTP id l131so2585420lfl.0
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 08:30:15 -0700 (PDT)
In-Reply-To: <CAJ3xEMiR3EODEV5aQ9cQG=7YZtVfFkbpHn79_j+s8H7XQ5F0rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 4:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Oct 17, 2016 at 11:30 PM, Eric Garver <e@erig.me> wrote:
>> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
>>
>> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
>> Signed-off-by: Eric Garver <e@erig.me>
>
> Dave,
>
> Hadar is OOO and I have asked Amir to look on the fix, will appreciate
> if we can have 24 hours to respond
>
> Or.

Reviewed and tested.

Acked-by: Amir Vadai <amir@vadai.me>
