From: Dan Luedtke <maildanrl@googlemail.com>
Subject: ping6: why TTL instead of Hop Limit?
Date: Sat, 7 Jan 2012 19:07:03 +0100
Message-ID: <CAAfuxnJX0ULFvUbrNag2TE3brTZiBv6x9X9_bKnAuD9Q_Oe1Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50756 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2AGSHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 13:07:05 -0500
Received: by yenm11 with SMTP id m11so1087603yen.19
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2012 10:07:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I was just wondering why there is a TTL-field in ping6, although the
corresponding field in the IPv6 header is called "Hop Limit". [1]

Example:
> ping6 -c 1 www.linux-ipv6.org
> 64 bytes from 2001:200:dff:fff1:216:3eff:fea4:f9e9: icmp_seq=1 ttl=48 time=309 ms

What I expected:
> 64 bytes from 2001:200:dff:fff1:216:3eff:fea4:f9e9: icmp_seq=1 hl=48 time=309 ms

Anyone an idea?
Should I write a patch or is there a special reason for this?

best regards,
Dan

[1] RFC 2460, 3.  IPv6 Header Format, page 4,
http://tools.ietf.org/html/rfc2460#page-4
-- 
Dan Luedtke
http://www.danrl.de
