From: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: this patch adds json support
 for bridge mdb show
Date: Mon, 24 Jul 2017 15:29:18 -0700
Message-ID: <7823F297-DB01-4C57-A8B8-296700A1184D@cumulusnetworks.com>
References: <1499466256-13808-1-git-send-email-roopa@cumulusnetworks.com>
 <20170718173351.55cb566a@xeon-e3>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33718 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbdGXW3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 18:29:20 -0400
Received: by mail-pf0-f180.google.com with SMTP id s70so51959085pfs.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 15:29:20 -0700 (PDT)
In-Reply-To: <20170718173351.55cb566a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,=20

Thanks you.
I will send an incremental patch with updated usage message and man =
page.

-Nikhil

> On Jul 18, 2017, at 5:33 PM, Stephen Hemminger =
<stephen@networkplumber.org> wrote:
>=20
> On Fri,  7 Jul 2017 15:24:16 -0700
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>=20
>> From: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
>>=20
>> This patch adds json output to bridge mdb show
>>=20
>> Normal Output:
>> $ bridge -d -s mdb show
>> dev br0 port swp3 grp 239.0.0.1 temp  vid 128 172.26
>> dev br0 port swp3 grp 239.0.0.1 temp  vid 64 172.26
>> dev br0 port swp2 grp 239.0.0.2 temp  vid 1024 172.26
>> dev br0 port swp2 grp 239.0.0.2 temp  vid 256 172.26
>> dev br0 port swp2 grp 239.0.0.2 temp  vid 1 172.26
>> dev br0 port swp3 grp 239.0.0.1 temp  vid 1 172.26
>> router ports on br0: swp4    0.00 permanent
>> router ports on br0: swp5    0.00 permanent
>>=20
>> Json Output:
>> $ bridge -d -s -j mdb show
>> {
>>    "mdb": [{
>>            "dev": "br0",
>>            "port": "swp3",
>>            "grp": "239.0.0.1",
>>            "state": "temp",
>>            "vid": 128,
>>            "timer": " 166.74"
>>        },{
>>            "dev": "br0",
>>            "port": "swp3",
>>            "grp": "239.0.0.1",
>>            "state": "temp",
>>            "vid": 64,
>>            "timer": " 166.74"
>>        },{
>>            "dev": "br0",
>>            "port": "swp2",
>>            "grp": "239.0.0.2",
>>            "state": "temp",
>>            "vid": 1024,
>>            "timer": " 166.74"
>>        },{
>>            "dev": "br0",
>>            "port": "swp2",
>>            "grp": "239.0.0.2",
>>            "state": "temp",
>>            "vid": 256,
>>            "timer": " 166.74"
>>        },{
>>            "dev": "br0",
>>            "port": "swp2",
>>            "grp": "239.0.0.2",
>>            "state": "temp",
>>            "vid": 1,
>>            "timer": " 166.74"
>>        },{
>>            "dev": "br0",
>>            "port": "swp3",
>>            "grp": "239.0.0.1",
>>            "state": "temp",
>>            "vid": 1,
>>            "timer": " 166.74"
>>        }
>>    ],
>>    "router": {
>>        "br0": [{
>>                "port": "swp4",
>>                "timer": "   0.00",
>>                "type": "permanent"
>>            },{
>>                "port": "swp5",
>>                "timer": "   0.00",
>>                "type": "permanent"
>>            }
>>        ]
>>    }
>> }
>>=20
>> Signed-off-by: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>=20
> Applied, you should also update usage message and man page.
