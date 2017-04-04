From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [PATCH] i40e: limit client interface to X722 hardware
Date: Tue, 4 Apr 2017 22:51:11 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D80544294@FMSMSX113.amr.corp.intel.com>
References: <20170404143446.16359-1-sassmann@kpanic.de>
 <CAJ3xEMjvmXTAyLP2-BwHRj59uQeCNXA7XSX7kTA=8TmwwmzRkw@mail.gmail.com>
 <b28317c2-fa35-2ee1-7bf2-c3ca7d24677b@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: 'Stefan Assmann' <sassmann@kpanic.de>,
        Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23928 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932257AbdDDWvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 18:51:16 -0400
In-Reply-To: <b28317c2-fa35-2ee1-7bf2-c3ca7d24677b@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbmV0ZGV2LW93bmVyQHZn
ZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+
IEJlaGFsZiBPZiBTdGVmYW4gQXNzbWFubg0KPiBTZW50OiBUdWVzZGF5LCBBcHJpbCAwNCwgMjAx
NyAxMjo1MiBQTQ0KPiBUbzogT3IgR2VybGl0eiA8Z2VybGl0ei5vckBnbWFpbC5jb20+DQo+IENj
OiBpbnRlbC13aXJlZC1sYW5AbGlzdHMub3N1b3NsLm9yZzsgTGludXggTmV0ZGV2IExpc3QNCj4g
PG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc+OyBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5u
ZXQ+OyBLaXJzaGVyLA0KPiBKZWZmcmV5IFQgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4N
Cj4gU3ViamVjdDogUmU6IFtQQVRDSF0gaTQwZTogbGltaXQgY2xpZW50IGludGVyZmFjZSB0byBY
NzIyIGhhcmR3YXJlDQo+IA0KPiBPbiAwNC4wNC4yMDE3IDE4OjU2LCBPciBHZXJsaXR6IHdyb3Rl
Og0KPiA+IE9uIFR1ZSwgQXByIDQsIDIwMTcgYXQgNTozNCBQTSwgU3RlZmFuIEFzc21hbm4gPHNh
c3NtYW5uQGtwYW5pYy5kZT4gd3JvdGU6DQo+ID4+IFRoZSBjbGllbnQgaW50ZXJmYWNlIGlzIG1l
YW50IGZvciBYNzIyIGlXQVJQIHN1cHBvcnQuIE1vZHByb2JpbmcgaTQwaXcNCj4gPj4gb24gc3lz
dGVtcyB3aXRoIFg3MTAvWEw3MTAgTklDcyBjdXJyZW50bHkgbWF5IGNyYXNoIHRoZSBzeXN0ZW0u
DQo+ID4NCj4gPiBqdXN0IGN1cmlvdXMgbWF5IG9yIGNyYXNoPyBhbmQgd2h5Pw0KPiANCj4gVGhl
IGJhY2t0cmFjZSBJIGdvdCB3YXMgbm90IHJlYWxseSBjb25jbHVzaXZlLiBUaGUgY29kZSBpcyBu
b3QgbWVhbnQgdG8NCj4gYmUgcnVuIG9uIHRoYXQgaGFyZHdhcmUgc28gSSBkaWRuJ3QgYm90aGVy
IHRvIGRpZyBkZWVwZXIuDQo+IA0KPiAgIFN0ZWZhbg0KDQpUaGUgaTQwaXcgbW9kdWxlIGNhbid0
IGVhc2lseSBkZXRlcm1pbmUgd2hpY2ggaGFyZHdhcmUgaXRzIGxvYWRlZCB1cG9uLiBTbyBpdCBh
c3N1bWVzIHRoYXQgd2UgKGk0MGUsIHRoYXQgaXMpIGhhdmUgaGFuZGVkIGl0IGEgaGFuZGxlIHRv
IHZhbGlkIGhhcmR3YXJlLiBXaGVuIHRoZSBpbnRlcmZhY2UgaXMgb3BlbmVkLCBpdCBzdGFydHMg
cmVhZGluZyBhbmQgd3JpdGluZyByZWdpc3RlcnMgdGhhdCBhcmUgbm9uZXhpc3RlbnQgb24gWDcx
MC9YTDcxMC4NCg0KLU1pdGNoDQo=
