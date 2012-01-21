From: Tom Gundersen <teg@jklm.no>
Subject: Re: Possible 3.3-rc1 regression: "ICMPv6 RA: ndisc_router_discovery()
 failed to add default route."
Date: Sat, 21 Jan 2012 19:10:16 +0100
Message-ID: <CAG-2HqWJo4D+seKHm6R0wkXeyW6a4XcK4JFtZ=HAzsDj+PJoCw@mail.gmail.com>
References: <CAG-2HqUBLN42REv1oojO0dD7nuVuM65_c3YQEF_gfByF0YbRMg@mail.gmail.com>
 <CAA93jw6Pi2KJPn+ykCqZDfdDTec5Ye8=NgQ1hR0dEHCQzu6jNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47502 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab2AUSKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 13:10:39 -0500
Received: by werb13 with SMTP id b13so1218440wer.19
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2012 10:10:37 -0800 (PST)
In-Reply-To: <CAA93jw6Pi2KJPn+ykCqZDfdDTec5Ye8=NgQ1hR0dEHCQzu6jNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2012 at 6:43 PM, Dave Taht <dave.taht@gmail.com> wrote:
> you kind of want
>
> ip -6 route show

Right, thanks:

# ip -6 route show
2a01:e35:2f24:93f0::/64 dev eth0  proto kernel  metric 256  expires 85836sec
unreachable fe80::/64 dev lo  proto kernel  metric 256  error -101
fe80::/64 dev eth0  proto kernel  metric 256
default via fe80::f6ca:e5ff:fe4a:f1a7 dev eth0  proto static  metric 1024

FWIW, it seems that I'm still able to connect to the network:
# ping6 2a00:1450:400c:c01::63
PING 2a00:1450:400c:c01::63(2a00:1450:400c:c01::63) 56 data bytes
64 bytes from 2a00:1450:400c:c01::63: icmp_seq=1 ttl=55 time=30.5 ms
