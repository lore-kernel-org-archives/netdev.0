From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC V3 PATCH 03/26] net/netpolicy: get device queue irq
 information
Date: Tue, 13 Sep 2016 13:22:50 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07750BBF5AA@SHSMSX103.ccr.corp.intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
 <1473692159-4017-4-git-send-email-kan.liang@intel.com>
 <665fd0a7-fe83-742a-28fd-d597b28505b5@cogentembedded.com>
 <37D7C6CF3E00A74B8858931C1DB2F07750BBF530@SHSMSX103.ccr.corp.intel.com>
 <CAKgT0Uf+guzBrfPUFvMk0RnXbQOJUjkBUp0TeK9HOSb_LU7e8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "gorcunov@openvz.org" <gorcunov@openvz.org>,
        "john.stultz@linaro.org" <john.stultz@linar
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Uf+guzBrfPUFvMk0RnXbQOJUjkBUp0TeK9HOSb_LU7e8Q@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gT24gVHVlLCBTZXAgMTMsIDIwMTYgYXQgNToyMyBBTSwgTGlhbmcsIEthbiA8a2FuLmxp
YW5nQGludGVsLmNvbT4gd3JvdGU6DQo+ID4+DQo+ID4+IEhlbGxvLg0KPiA+Pg0KPiA+PiBPbiAw
OS8xMi8yMDE2IDA1OjU1IFBNLCBrYW4ubGlhbmdAaW50ZWwuY29tIHdyb3RlOg0KPiA+Pg0KPiA+
PiA+IEZyb206IEthbiBMaWFuZyA8a2FuLmxpYW5nQGludGVsLmNvbT4NCj4gPj4gPg0KPiA+PiA+
IE5ldCBwb2xpY3kgbmVlZHMgdG8ga25vdyBkZXZpY2UgaW5mb3JtYXRpb24uIEN1cnJlbnRseSwg
aXQncyBlbm91Z2gNCj4gPj4gPiB0byBvbmx5IGdldCBpcnEgaW5mb3JtYXRpb24gb2YgcnggYW5k
IHR4IHF1ZXVlcy4NCj4gPj4gPg0KPiA+PiA+IFRoaXMgcGF0Y2ggaW50cm9kdWNlcyBuZG8gb3Bz
IHRvIGRvIHNvLCBub3QgZXRodG9vbCBvcHMuDQo+ID4+ID4gQmVjYXVzZSB0aGVyZSBhcmUgYWxy
ZWFkeSBzZXZlcmFsIHdheXMgdG8gZ2V0IGlycSBpbmZvcm1hdGlvbiBpbg0KPiA+PiA+IHVzZXJz
cGFjZS4gSXQncyBub3QgbmVjZXNzb3J5IHRvIGV4dGVuZCB0aGUgZXRodG9vbC4NCj4gPj4NCj4g
Pj4gICAgIE5lY2Vzc2FyeS4NCj4gPg0KPiA+IE9LLiBJIHdpbGwgZXh0ZW5kIHRoZSBldGh0b29s
IGluIG5leHQgdmVyc2lvbi4NCj4gPg0KPiA+IFRoYW5rcywNCj4gPiBLYW4NCj4gDQo+IEthbiwg
SSBkb24ndCB0aGluayBTZXJnZWkgd2FzIHNheWluZyB5b3UgaGF2ZSB0byBleHRlbmQgdGhlIGV0
aHRvb2wuDQo+IFlvdXIgc3BlbGxpbmcgb2YgbmVjZXNzYXJ5IHdhcyBpbmNvcnJlY3QgaW4geW91
ciBwYXRjaCBkZXNjcmlwdGlvbi4NCj4gDQo+IFNlcmdlaSwgcGxlYXNlIGZlZWwgZnJlZSB0byB0
ZWxsIG1lIEkgYW0gd3JvbmcgaWYgbXkgYXNzdW1wdGlvbiBvbiB0aGF0IGlzDQo+IGluY29ycmVj
dC4NCj4gDQo+IC0gQWxleA0KDQpPaCwgSSBzZWUuIFRoYW5rcyBBbGV4LiA6KQ0KDQpLYW4NCg0K
DQo=
