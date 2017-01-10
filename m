From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Tue, 10 Jan 2017 11:29:40 +0900
Message-ID: <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com>
References: <20170106153026.24785-1-lorenzo@google.com> <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com> <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Erik Kline <ek@google.com>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        David Miller <davem@davemloft.net>,
        Daniel Rosenberg <drosen@google.com>, temnota.am@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36045 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161782AbdAJCaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 21:30:02 -0500
Received: by mail-vk0-f46.google.com with SMTP id t8so18985674vke.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 18:30:02 -0800 (PST)
In-Reply-To: <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 11:08 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> That's news to me. What about IPv6 and VRF is not working or well-supported?

I have no firsthand experience of this myself, but if the problems
that Andrey reports above in this thread are real, then those would
indicate that the code is not well-supported. Being unable to accept
DAD is a pretty serious issue. Andrey, what version of the kernel did
you see this on?
