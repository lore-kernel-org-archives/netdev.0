From: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Subject: Re: [PATCH v2] netfilter: Clean up tests if NULL returned on failure
Date: Tue, 28 Mar 2017 21:53:30 +0530
Message-ID: <CALrZqyPeR6X1RrqOsGfLbbZ2rPQgOf=50Rs+ot0kxkkA464V5w@mail.gmail.com>
References: <20170328131340.GA19688@singhal-Inspiron-5558> <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>,
        Julian Anastasov <ja@ssi.bg>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        outreachy-kernel <outreachy-kernel@googlegroups.com>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:33811 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752447AbdC1QXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 12:23:38 -0400
In-Reply-To: <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 7:24 PM, Jan Engelhardt <jengelh@inai.de> wrote:
> On Tuesday 2017-03-28 15:13, simran singhal wrote:
>
>>Some functions like kmalloc/kzalloc return NULL on failure. When NULL
>>represents failure, !x is commonly used.
>>
>>@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>>       }
>>
>>       dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>>-      if (dest == NULL)
>>+      if (!dest)
>>               return -ENOMEM;
>
> This kind of transformation however is not cleanup anymore, it's really
> bikeshedding and should be avoided. There are pro and cons for both
> variants, and there is not really an overwhelming number of arguments
> for either variant to justify the change.

Sorry, but I didn't get what you are trying to convey. And particularly pros and
cons of both variants.
