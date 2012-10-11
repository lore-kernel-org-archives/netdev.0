From: Lin Ming <minggr@gmail.com>
Subject: IGMP fast leave
Date: Thu, 11 Oct 2012 15:16:30 +0800
Message-ID: <CAF1ivSZjCKVgjvg46a98SmbXPGk_ofPKR_mjdMJKZQ0Rf2GYdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: networking <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:43523 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755628Ab2JKHQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 03:16:32 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so991201lag.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 00:16:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm testing multicast on a router running 2.6.32 kernel.

For fast leave support, I expect that the router should stop sending
immediately the multicast stream when receiving an IGMP leave for the
last member.

2.6.32 kernel does not support this kind of fast leave.
Does latest kernel support it?

Thanks,
Lin Ming
