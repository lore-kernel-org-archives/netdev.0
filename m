From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] tcp: diag: add support for request sockets to tcp_abort()
Date: Sat, 19 Dec 2015 16:12:13 +0900
Message-ID: <CAKD1Yr1soLjw3Xx-7veCWJ9OXSANznZ_wbRCD5qocHUqqUrY8Q@mail.gmail.com>
References: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAKD1Yr11jzdP3hfK3qk+-mkOV1Pc3DCi+Pmf=noT3SDJP6ZTGA@mail.gmail.com> <1450442811.8474.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35970 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbbLSHMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 02:12:33 -0500
Received: by mail-yk0-f179.google.com with SMTP id x184so83735475yka.3
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 23:12:33 -0800 (PST)
In-Reply-To: <1450442811.8474.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 9:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Tested-by: Lorenzo Colitti <lorenzo@google.com>
>
> I am curious, did you use packetdrill for this ?

No, I added this to our existing kernel networking tests:

https://android-review.googlesource.com/#/c/187491/

The tests are written in Python and run under ARCH=um. They use Python
code to exercise the kernel socket and netlink APIs on one side, and
use scapy on multiple tap interfaces to simulate the networks. They
were initially written to check that routing on a multinetwork device
would work properly.

https://android.googlesource.com/platform/system/extras/+/master/tests/net_test
