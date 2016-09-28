From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:09:28 -0400
Message-ID: <60b2e075-e852-f0c2-c188-631f547791d5@mojatatu.com>
References: <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
 <20160928112703.GW1876@uranus.lan>
 <20160928.080701.1194277590163223525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33567 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753442AbcI1MJc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:09:32 -0400
Received: by mail-io0-f195.google.com with SMTP id r145so3028702ior.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:09:31 -0700 (PDT)
In-Reply-To: <20160928.080701.1194277590163223525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-28 08:07 AM, David Miller wrote:

> Right, it would be legal for an existing user to have code that
> explicitly initializes every member of the structure, including 'pad'.
> So we have to keep that member around, at a minimum, for their sake.
>

I think we need to start labelling any new pad fields added as
"Not UAPI. Do not fsck fondle this".

cheers,
jamal
