From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding Routing cache
Date: Thu, 17 Nov 2011 10:30:59 +0530
Message-ID: <CADAe=+Lmp=e3NRH5NOYewJp=XZ0CncPzC-4V=Ct-TEuGjfq3nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42603 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab1KQFBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 00:01:31 -0500
Received: by fagn18 with SMTP id n18so2446013fag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 21:01:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a small doubt regarding routing cache in linux kernel.

It seems ip_route_connect is the way we have to access routing cache
entries. In case of all locally generated packets I see that struct
dst_entry is filled up with a lookup in routing cache.

What about in case of forwarding packets ? I dont see any usage of
routing cache mechanism to fill up the struct dst_entry. So it seems
we directly check the fib_rules or fib table to fill the structure.
If it is true then it would be very slow right ?

Sorry if I am wrong about above findings. Do correct me if I am wrong about it ?

Regards,
Ajith
