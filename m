From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] xfrm: Clear sk_dst_cache when applying per-socket policy.
Date: Wed, 16 Aug 2017 18:03:17 +0900
Message-ID: <CAKD1Yr3uJCSBPtCds+ckXDusmCC-qMojDjtMFa1UAm_vcR1cUg@mail.gmail.com>
References: <20170815222510.21711-1-misterikkit@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jkbs@redhat.com,
        David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Jonathan Basseri <misterikkit@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:33443 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbdHPJDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 05:03:39 -0400
Received: by mail-it0-f43.google.com with SMTP id f16so18621655itb.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 02:03:38 -0700 (PDT)
In-Reply-To: <20170815222510.21711-1-misterikkit@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 7:25 AM, Jonathan Basseri
<misterikkit@google.com> wrote:
> If an IPv6 socket has a valid dst cache

Did you look into why IPv4 does not suffer from this problem?

That said, clearing the dst cache entry does seem prudent in general.
