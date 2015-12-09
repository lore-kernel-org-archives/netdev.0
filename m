From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] ip_tunnel: Move stats update to iptunnel_xmit()
Date: Wed, 9 Dec 2015 14:53:39 -0800
Message-ID: <CALnjE+o9ktUFi9SYvGbPcP5e3pjMpi=ebTJxaH8KMGpBkcKQgQ@mail.gmail.com>
References: <1449631354-3701-1-git-send-email-pshelar@nicira.com>
	<20151208.224120.451853113571251140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35299 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbLIWxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:53:40 -0500
Received: by ioc74 with SMTP id 74so76189940ioc.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:53:39 -0800 (PST)
In-Reply-To: <20151208.224120.451853113571251140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 7:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue,  8 Dec 2015 19:22:34 -0800
>
>> By moving stats update into iptunnel_xmit(), we can simplify
>> iptunnel_xmit() usage. With this change there is no need to
>> call another function (iptunnel_xmit_stats()) to update stats
>> in tunnel xmit code path.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> You're going to have to respin this relative to the fix I just
> put into 'net'.

ok, I will wait for the net -> net-next merge.
