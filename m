From: Neil McKee <neil.mckee@inmon.com>
Subject: Re: [PATCH net-next] openvswitch: include actions with upcall if
 allocation allows
Date: Thu, 4 Jun 2015 15:51:53 -0700
Message-ID: <CAB1FvaKVYhmM2p85VmYMnMTTtNxyxBbR7rTZV+fGS9mwpDvNWw@mail.gmail.com>
References: <1433370667-30625-1-git-send-email-neil.mckee@inmon.com> <20150604.011353.1589451290206511811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34598 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbFDWwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 18:52:15 -0400
Received: by laew7 with SMTP id w7so42238143lae.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 15:52:13 -0700 (PDT)
In-Reply-To: <20150604.011353.1589451290206511811.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 1:13 AM, David Miller <davem@davemloft.net> wrote:
> From: Neil McKee <neil.mckee@inmon.com>
> Date: Wed,  3 Jun 2015 15:31:07 -0700
>
>> Back out the OVS_USERSPACE_ATTR_ACTIONS attribute that was
>> gating the inclusion of datapath actions in the upcall.
>> Instead include the actions every time, provided there is no
>> problem with the atomic allocation.  If the atomic allocation
>> fails then try it again with the actions omitted.
>>
>> Signed-off-by: Neil McKee <neil.mckee@inmon.com>
>
> Conditionally providing the attributes to the user is completely
> terrible semantics.
>
> If the user really needs these, then he won't be happy to get the
> upcall without them, he'd rather the upcall fail completely
> instead.
>
> I'm not applying this patch, this change was not well thought out
> at all.

OK.  We can use the OVS_USERSPACE_ATTR_ACTIONS mechanism that you
checked in already.   Thanks!
