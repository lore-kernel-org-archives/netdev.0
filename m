From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding Routing cache
Date: Thu, 17 Nov 2011 11:34:08 +0530
Message-ID: <CADAe=+K8bf_VOe=KszDZRqZnxQH2VFS3C05mpG=RarN+R5BSbA@mail.gmail.com>
References: <CADAe=+Lmp=e3NRH5NOYewJp=XZ0CncPzC-4V=Ct-TEuGjfq3nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50033 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1KQGEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 01:04:41 -0500
Received: by fagn18 with SMTP id n18so2469174fag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 22:04:40 -0800 (PST)
In-Reply-To: <CADAe=+Lmp=e3NRH5NOYewJp=XZ0CncPzC-4V=Ct-TEuGjfq3nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Actually I have doubt with IPv6 related packets.

In case of IPv6 packet in ip6_route_output function is called for
destination related information.
where ip6_route_output calls "fib6_rule_lookup" function. Why lookup
is done in fib table instead of routing cache in case of IPv6 packet ?

In case of IPv4 packet ... ip_route_output checks in routing cache and
if there is a cache miss then it checks the fib table.

Regards,
Ajith




On Thu, Nov 17, 2011 at 10:30 AM, Ajith Adapa <adapa.ajith@gmail.com> wrote:
> Hi,
>
> I have a small doubt regarding routing cache in linux kernel.
>
> It seems ip_route_connect is the way we have to access routing cache
> entries. In case of all locally generated packets I see that struct
> dst_entry is filled up with a lookup in routing cache.
>
> What about in case of forwarding packets ? I dont see any usage of
> routing cache mechanism to fill up the struct dst_entry. So it seems
> we directly check the fib_rules or fib table to fill the structure.
> If it is true then it would be very slow right ?
>
> Sorry if I am wrong about above findings. Do correct me if I am wrong about it ?
>
> Regards,
> Ajith
>
