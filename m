From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 8/8] net: ipv6: RTM_GETROUTE: return matched fib
 result when requested
Date: Thu, 25 May 2017 10:00:36 -0600
Message-ID: <5917C4F8-5C96-4BE9-B276-2875561D5A60@gmail.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
 <1495649951-30417-9-git-send-email-roopa@cumulusnetworks.com>
 <2106987d-7c19-b739-0103-97af3a3071da@gmail.com>
 <CAJieiUh+GAtOGZv4UU_gcn5isA6DSqaFj_EXzA24qBK7vJz4AQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34178 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938517AbdEYQAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:00:44 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so40096433pfk.1
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:00:44 -0700 (PDT)
In-Reply-To: <CAJieiUh+GAtOGZv4UU_gcn5isA6DSqaFj_EXzA24qBK7vJz4AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 25, 2017, at 9:54 AM, Roopa Prabhu <roopa@cumulusnetworks.com> =
wrote:
>=20
>>=20
>> I'd prefer to see the typecasts go away and use container_of to go =
from
>> dst_entry to rt6_info. I realize some of this is movement of existing
>> code, but better to clean up as we go.
>>=20
>=20
> ack. But that is pretty much all of ipv6 code. so, seems better done
> with an incremental cleanup patch.
>=20

For the rest of the ipv6 code, yes. We can do the right thing now for =
new code and changes to existing code.=
