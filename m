From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 2/3] ipvlan: mode is u16
Date: Mon, 8 Feb 2016 14:14:54 -0800
Message-ID: <CAF2d9jjXdmJQpzxVYvBKrfdo+-9Qb_6xwSO7Uzsrfq5QgPmkMw@mail.gmail.com>
References: <1454440830-2108-1-git-send-email-mahesh@bandewar.net> <20160207.141911.1789162712081045670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mahesh@bandewar.net, Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36178 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbcBHWPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 17:15:14 -0500
Received: by mail-yw0-f181.google.com with SMTP id q190so113591896ywd.3
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 14:15:14 -0800 (PST)
In-Reply-To: <20160207.141911.1789162712081045670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 7, 2016 at 11:19 AM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <mahesh@bandewar.net>
> Date: Tue,  2 Feb 2016 11:20:30 -0800
>
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> The mode argument was erronusly defined as u32 but it has always
>> been u16.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> This patch is changing more than this.
>
> Specifically it is invoking ipvlan_set_port_mode() instead of assigning
> port->mode directly in ipvlan_link_new().
>
> That minimally needs to be documented in the commit log message.
>
> But I also wonder if for some reason in this conect the direct
> assignment happens to be fine.  That's pretty much why you should
> explain things.

Directly assigning does serve the same purpose, however when there is
a helper to do just that (and other things in future) it would help
keep all related things at one place avoiding errors in future. Since
it's a minor improvement I did not mention that into the commit log.

I'll update the commit log and resend.
