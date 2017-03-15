From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Wed, 15 Mar 2017 12:18:16 +0100
Message-ID: <a38da3b2-5df5-1f3d-1a6c-a8cbf98b6140@6wind.com>
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
 <B403ACFE-A028-454D-94C1-F7023457C87C@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36228 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751885AbdCOLSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:18:20 -0400
Received: by mail-wr0-f182.google.com with SMTP id u108so8664573wrb.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:18:18 -0700 (PDT)
In-Reply-To: <B403ACFE-A028-454D-94C1-F7023457C87C@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/03/2017 à 11:46, Nikolay Aleksandrov a écrit :
[snip]
> This doesn’t fit the NETCONFA model well, there is no “all”, “default” or per iface option to be set, also
> the other multipath sysctl which affects behaviour doesn’t have a notification.
Right. Maybe adding a "system-wide" option can help, but it's probably another
patch to add netconf support for other ecmp properties.


Thank you,
Nicolas
