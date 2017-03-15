From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Wed, 15 Mar 2017 13:27:14 +0200
Message-ID: <7782A16C-78B4-4A5D-BE8D-6DDF2E9B3C66@cumulusnetworks.com>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com> <20170314085502.47d48a4e@xeon-e3> <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com> <20170314.114837.619141079617104809.davem@davemloft.net> <20170314132506.6233b1e7@xeon-e3> <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com> <20170314144204.20d5c3a5@xeon-e3> <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com> <20170314162715.141f1d4b@xeon-e3> <0c0473f7-beab-ea87-6dde-77aa345258ff@cumulusnetworks.com> <5b5cf0ac-d152-3c8e-d54b-1059f561efee@6wind.com> <B403ACFE-A028-454D-94C1-F7023457C87C@cumulusnetworks.com> <a38da3b2-5df5-1f3d-1a6c-a8cbf98b6140@6wind.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37205 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbdCOL2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:28:03 -0400
Received: by mail-wm0-f48.google.com with SMTP id n11so20375133wma.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:28:02 -0700 (PDT)
In-Reply-To: <a38da3b2-5df5-1f3d-1a6c-a8cbf98b6140@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 15, 2017, at 1:18 PM, Nicolas Dichtel =
<nicolas.dichtel@6wind.com> wrote:
>=20
> Le 15/03/2017 =E0 11:46, Nikolay Aleksandrov a =E9crit :
> [snip]
>> This doesn=92t fit the NETCONFA model well, there is no =93all=94, =
=93default=94 or per iface option to be set, also
>> the other multipath sysctl which affects behaviour doesn=92t have a =
notification.
> Right. Maybe adding a "system-wide" option can help, but it's probably =
another
> patch to add netconf support for other ecmp properties.
>=20
>=20
> Thank you,
> Nicolas

Yep, sounds good.
I=92ll add the netlink support for system-wide NETCONFA and ecmp as =
follow up patches so we can
have a separate discussion on the design there.

Thanks,
 Nik
