From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 04 Nov 2015 07:13:07 -0800
Message-ID: <1446649987.4184.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	 <3363088.63t9TqhiQf@stwm.de>
	 <1446640851.4184.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2511200.aYIar34voW@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33186 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965471AbbKDPNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:13:11 -0500
Received: by pabfh17 with SMTP id fh17so55644599pab.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 07:13:10 -0800 (PST)
In-Reply-To: <2511200.aYIar34voW@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 15:09 +0100, Wolfgang Walter wrote:

> 
> Yes, maybe igb has a problem sending a gro-packet if it is an isatap in gre.

We might detect this condition properly from igb ndo_features_check
method.

It currently uses plain passthru_features_check()



> 
> igb has no problem sending gro-packets which are pure isatap or which are ipv4 
> (tcp/udp) in gre with 4.1.12 + these patches.
> 
> And it had no problem with 4.1.11 with isatap in gre.
> 
> Disabling gso for the interface does help.

My patch was aimed for 4.4, not sure about backports to old kernels...
