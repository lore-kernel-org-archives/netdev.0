From: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>
Subject: RE: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Tue, 31 Jan 2017 07:10:08 +0000
Message-ID: <CS1PR84MB0072BE86ADF00FBE07959F3DCA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
 <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
 <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com>
 <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
 <CAM_iQpWmygXWcda825XY0LsaYQ6KbG9cwsNYpTKbq4T0_2UwnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Elad Raz <e@eladraz.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0135.outbound.protection.outlook.com ([104.47.38.135]:31968
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750856AbdAaHKP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 02:10:15 -0500
In-Reply-To: <CAM_iQpWmygXWcda825XY0LsaYQ6KbG9cwsNYpTKbq4T0_2UwnQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSBhbSBvZiA0LjQuMTguIEkgc2VlIHRoZSBjb21taXQgaXMgbm90IHByZXNlbnQuIEkgd2lsbCBy
ZWNvbXBpbGUgbXkga2VybmVsIHdpdGggYmVsb3cgcGF0Y2guDQoNClRoYW5rcyBmb3IgdGhlIHF1
aWNrIHNoYSByZWZlcmVuY2UuDQoNClRoYW5rcw0KS3Jpc2huYSBNb2hhbi4NCg0KLS0tLS1Pcmln
aW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IENvbmcgV2FuZyBbbWFpbHRvOnhpeW91Lndhbmdjb25n
QGdtYWlsLmNvbV0gDQpTZW50OiBUdWVzZGF5LCBKYW51YXJ5IDMxLCAyMDE3IDEyOjIzIFBNDQpU
bzogRWxsdXJ1LCBLcmlzaG5hIE1vaGFuIDxlbGx1cnUua3JpLm1vaGFuQGhwZS5jb20+DQpDYzog
RWxhZCBSYXogPGVAZWxhZHJhei5jb20+OyBOaWNvbGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRl
bEA2d2luZC5jb20+OyBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+OyBMaW51eCBO
ZXRkZXYgTGlzdCA8bmV0ZGV2QHZnZXIua2VybmVsLm9yZz47IEppcmkgUGlya28gPGppcmlAcmVz
bnVsbGkudXM+OyBJZG8gU2NoaW1tZWwgPGlkb3NjaEBtZWxsYW5veC5jb20+OyBZb3RhbSBHaWdp
IDx5b3RhbWdAbWVsbGFub3guY29tPg0KU3ViamVjdDogUmU6IFtQYXRjaCBuZXQtbmV4dCAyLzJd
IG5ldG5zOiBhdm9pZCBkaXNhYmxpbmcgaXJxIGZvciBuZXRucyBpZA0KDQpPbiBNb24sIEphbiAz
MCwgMjAxNyBhdCAxMDo0NyBQTSwgRWxsdXJ1LCBLcmlzaG5hIE1vaGFuIDxlbGx1cnUua3JpLm1v
aGFuQGhwZS5jb20+IHdyb3RlOg0KPiBISSBDb25nLA0KPiAgICAgICAgIEhhdmUgeW91IHBvc3Rl
ZCBhbnkgcGF0Y2ggZm9yIHRoZSBzYW1lPyBJIGFtIGxvb2tpbmcgZm9yIHNpbmdsZSBuZXRsaW5r
IHNvY2tldCB0byBoYW5kbGUgbXVsdGlwbGUgbmV0d29yayBuYW1lc3BhY2UgZXZlbnRzIHVzaW5n
IE5FVExJTktfTElTVEVOX0FMTF9OU0lELiBJIGRvbid0IHNlZSBkZXRlY3Rpb24gb2YgbmV3IG5h
bWVzcGFjZXMgYnkgdGhpcyBzb2NrZXQgeWV0IGFuZCBjYXVzaW5nIHVwZGF0ZXMgdG8gYmUgbWlz
c2VkLg0KDQpUaGUgcGF0Y2ggaW4gJHN1YmplY3Qgd2FzIHJlcG9zdGVkIGJ5IFBhdWwgYWZ0ZXIg
Zml4aW5nIHRoZSBhdWRpdCBwYXJ0Og0KDQpjb21taXQgZmJhMTQzYzY2YWJiODEzMDdhNDUwNjc5
ZjM4YWI5NTNmZTk2YTQxMw0KQXV0aG9yOiBQYXVsIE1vb3JlIDxwYXVsQHBhdWwtbW9vcmUuY29t
Pg0KRGF0ZTogICBUdWUgTm92IDI5IDE2OjU3OjQ4IDIwMTYgLTA1MDANCg0KICAgIG5ldG5zOiBh
dm9pZCBkaXNhYmxpbmcgaXJxIGZvciBuZXRucyBpZA0KDQpXaGljaCB2ZXJzaW9uIG9mIGtlcm5l
bCBhcmUgeW91IHRlc3Rpbmc/IERvZXMgaXQgaGF2ZSB0aGlzIGNvbW1pdD8NCg0KVGhhbmtzLg0K
