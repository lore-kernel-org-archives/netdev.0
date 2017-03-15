From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Wed, 15 Mar 2017 09:01:16 -0600
Message-ID: <5c0b73c5-ee6b-d67f-b01e-0d749c8ced6d@cumulusnetworks.com>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170314085502.47d48a4e@xeon-e3>
 <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
 <20170314.114837.619141079617104809.davem@davemloft.net>
 <20170314132506.6233b1e7@xeon-e3>
 <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com>
 <20170314144204.20d5c3a5@xeon-e3>
 <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com>
 <20170314162715.141f1d4b@xeon-e3>
 <0c0473f7-beab-ea87-6dde-77aa345258ff@cumulusnetworks.com>
 <5b5cf0ac-d152-3c8e-d54b-1059f561efee@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: nicolas.dichtel@6wind.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36323 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753137AbdCOPBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:01:20 -0400
Received: by mail-pg0-f43.google.com with SMTP id g2so10331424pge.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:01:19 -0700 (PDT)
In-Reply-To: <5b5cf0ac-d152-3c8e-d54b-1059f561efee@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/17 3:17 AM, Nicolas Dichtel wrote:
>>> Is there another patch to add the NETCONFA_ECMP support?
>>>
>>
>> does userspace care?
> Yes, I think it is needed so that userspace can correctly monitor this behavior.
> It also enables to check this parameter through netlink.
> 

I don't understand why userspace cares. What can userspace do with that
information?
