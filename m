From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v2] e1000e: Don't return uninitialized stats
Date: Fri, 19 May 2017 21:12:58 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5F9877@ORSMSX101.amr.corp.intel.com>
References: <20170425175433.ykc6ilm6uo7e6my2@f1.synalogic.ca>
         <20170517202413.18321-1-bpoirier@suse.com>
         <20170518.104614.1739169308591707817.davem@davemloft.net>
 <1495181811.2376.0.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "s.priebe@profihost.ag" <s.priebe@profihost.ag>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "pmenzel@molgen.mpg.de" <pmenzel@molgen.mpg.de>,
        "Neftin, Sasha" <sasha.neftin@intel.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        "bpoirier@suse.com" <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:9948 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755220AbdESVM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 17:12:59 -0400
In-Reply-To: <1495181811.2376.0.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBLaXJzaGVyLCBKZWZmcmV5IFQNCj4gU2VudDogRnJpZGF5LCBNYXkgMTksIDIwMTcg
MToxNyBBTQ0KPiBUbzogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PjsgYnBvaXJp
ZXJAc3VzZS5jb20NCj4gQ2M6IHMucHJpZWJlQHByb2ZpaG9zdC5hZzsgaW50ZWwtd2lyZWQtbGFu
QGxpc3RzLm9zdW9zbC5vcmc7DQo+IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHBtZW56ZWxAbW9s
Z2VuLm1wZy5kZTsgTmVmdGluLCBTYXNoYQ0KPiA8c2FzaGEubmVmdGluQGludGVsLmNvbT47IEJy
b3duLCBBYXJvbiBGIDxhYXJvbi5mLmJyb3duQGludGVsLmNvbT47DQo+IHN0ZXBoZW5AbmV0d29y
a3BsdW1iZXIub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggdjJdIGUxMDAwZTogRG9uJ3QgcmV0
dXJuIHVuaW5pdGlhbGl6ZWQgc3RhdHMNCj4gDQo+IE9uIFRodSwgMjAxNy0wNS0xOCBhdCAxMDo0
NiAtMDQwMCwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+IEZyb206IEJlbmphbWluIFBvaXJpZXIg
PGJwb2lyaWVyQHN1c2UuY29tPg0KPiA+IERhdGU6IFdlZCwgMTcgTWF5IDIwMTcgMTY6MjQ6MTMg
LTA0MDANCj4gPg0KPiA+ID4gU29tZSBzdGF0aXN0aWNzIHBhc3NlZCB0byBldGh0b29sIGFyZSBn
YXJiYWdlIGJlY2F1c2UNCj4gPiA+IGUxMDAwZV9nZXRfc3RhdHM2NCgpDQo+ID4gPiBkb2Vzbid0
IHdyaXRlIHRoZW0sIGZvciBleGFtcGxlOiB0eF9oZWFydGJlYXRfZXJyb3JzLiBUaGlzIGxlYWtz
IGtlcm5lbA0KPiA+ID4gbWVtb3J5IHRvIHVzZXJzcGFjZSBhbmQgY29uZnVzZXMgdXNlcnMuDQo+
ID4gPg0KPiA+ID4gRG8gbGlrZSBpeGdiZSBhbmQgdXNlIGRldl9nZXRfc3RhdHMoKSB3aGljaCBm
aXJzdCB6ZXJvZXMgb3V0DQo+ID4gPiBydG5sX2xpbmtfc3RhdHM2NC4NCj4gPiA+DQo+ID4gPiBG
aXhlczogNTk0NDcwMWRmOTBkICgibmV0OiByZW1vdmUgdXNlbGVzcyBtZW1zZXQncyBpbiBkcml2
ZXJzDQo+ID4gPiBnZXRfc3RhdHM2NCIpDQo+ID4gPiBSZXBvcnRlZC1ieTogU3RlZmFuIFByaWVi
ZSA8cy5wcmllYmVAcHJvZmlob3N0LmFnPg0KPiA+ID4gU2lnbmVkLW9mZi1ieTogQmVuamFtaW4g
UG9pcmllciA8YnBvaXJpZXJAc3VzZS5jb20+DQoNClRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFh
cm9uLmYuYnJvd25AaW50ZWwuY29tPg0K
