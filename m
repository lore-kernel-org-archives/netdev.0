From: Patrick Ruddy <pruddy@Brocade.com>
Subject: Re: [net-next PATCH] net: netlink messages for HW addr programming
Date: Mon, 3 Oct 2016 10:42:55 +0000
Message-ID: <1475491377.29766.35.camel@brocade.com>
References: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
         <57DEA9E2.3000703@cumulusnetworks.com>
         <1474296378.31262.59.camel@brocade.com>
         <57E0C9AF.4090406@cumulusnetworks.com>
         <20160920054959.GB1843@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Luca Boccassi <lboccass@Brocade.com>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "Sven-Thorsten Dietrich" <sven@brocade.com>
To: "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47954 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751157AbcJCKnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 06:43:05 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
        by mx0a-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u93AgS1W001355
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 03:43:04 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0a-000f0801.pphosted.com with ESMTP id 25tcj0cwe2-2
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 03:43:03 -0700
In-Reply-To: <20160920054959.GB1843@nanopsycho.orion>
Content-Language: en-US
Content-ID: <41A0C957FD9AA24EAFF72245A929FF31@brocade.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE2LTA5LTIwIGF0IDA3OjQ5ICswMjAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBU
dWUsIFNlcCAyMCwgMjAxNiBhdCAwNzozMToyN0FNIENFU1QsIHJvb3BhQGN1bXVsdXNuZXR3b3Jr
cy5jb20gd3JvdGU6DQo+ID5PbiA5LzE5LzE2LCA3OjQ2IEFNLCBQYXRyaWNrIFJ1ZGR5IHdyb3Rl
Og0KPiA+PiBPbiBTdW4sIDIwMTYtMDktMTggYXQgMDc6NTEgLTA3MDAsIFJvb3BhIFByYWJodSB3
cm90ZToNCj4gPj4+IE9uIDkvMTUvMTYsIDk6NDggQU0sIFBhdHJpY2sgUnVkZHkgd3JvdGU6DQo+
ID4+Pj4gQWRkIFJUTV9ORVdBRERSIGFuZCBSVE1fREVMQUREUiBuZXRsaW5rIG1lc3NhZ2VzIHdp
dGggZmFtaWx5DQo+ID4+Pj4gQUZfVU5TUEVDIHRvIGluZGljYXRlIGludGVyZXN0IGluIHNwZWNp
ZmljIHVuaWNhc3QgYW5kIG11bHRpY2FzdA0KPiA+Pj4+IGhhcmR3YXJlIGFkZHJlc3Nlcy4gVGhl
c2UgbWVzc2FnZXMgYXJlIHNlbnQgd2hlbiBhZGRyZXNzZXMgYXJlDQo+ID4+Pj4gYWRkZWQgb3Ig
ZGVsZXRlZCBmcm9tIHRoZSBhcHByb3ByaWF0ZSBpbnRlcmZhY2UgZHJpdmVyLg0KPiA+Pj4+IEFk
ZGVkIEFGX1VOU1BFQyBHRVRBRERSIGZ1bmN0aW9uIHRvIGFsbG93IHRoZSBuZXRsaW5rIG5vdGlm
aWNhdGlvbnMNCj4gPj4+PiB0byBiZSByZXBsYXllZCB0byBhdm9pZCBsb3NzIG9mIHN0YXRlIGR1
ZSB0byBhcHBsaWNhdGlvbiBzdGFydA0KPiA+Pj4+IG9yZGVyaW5nIG9yIHJlc3RhcnQuDQo+ID4+
Pj4NCj4gPj4+PiBTaWduZWQtb2ZmLWJ5OiBQYXRyaWNrIFJ1ZGR5IDxwcnVkZHlAYnJvY2FkZS5j
b20+DQo+ID4+Pj4gLS0tDQo+ID4+PiBSVE1fTkVXQUREUiBhbmQgUlRNX0RFTEFERFIgYXJlIG5v
dCB1c2VkIHRvIGFkZCB0aGVzZSBlbnRyaWVzIHRvIHRoZSBrZXJuZWwuDQo+ID4+PiBzbywgaXQg
c2VlbXMgYSBiaXQgd3JvbmcgdG8gdXNlIFJUTV9ORVdBRERSIGFuZCBSVE1fREVMQUREUiB0byBu
b3RpZnkgdGhlbSB0bw0KPiA+Pj4gdXNlcnNwYWNlIGFuZCBhbHNvIHRvIHJlcXVlc3QgYSBzcGVj
aWFsIGR1bXAgb2YgdGhlc2UgYWRkcmVzc2VzLg0KPiA+Pj4NCj4gPj4+IFRoaXMgY291bGQganVz
dCBiZSBhIG5ldyBuZXN0ZWQgbmV0bGluayBhdHRyaWJ1dGUgaW4gdGhlIGV4aXN0aW5nIGxpbmsg
ZHVtcCA/DQo+ID4+IEhpIFJvb3BhDQo+ID4+DQo+ID4+IFRoYW5rcyBmb3IgdGhlIHJldmlldy4g
SSBkaWQgaW5pdGlhbGx5IGNvZGUgdGhpcyB1c2luZyBORVcvREVML0dFVF9MSU5LDQo+ID4+IG1l
c3NhZ2VzIGJ1dCB3YXMgYXNrZWQgdG8gY2hhbmdlIHRvIHRvIEFERFIgbWVzc2FnZXMgYnkgU3Rl
cGhlbg0KPiA+PiBIZW1taW5nZXIgKGNjJ2QpLiANCj4gPj4NCj4gPj4gSG93ZXZlciBJIGFncmVl
IHRoYXQgdGhlc2UgYWRkcmVzc2VzIGZhbGwgYmV0d2VlbiB0aGUgTElOSyBhbmQgQUREUg0KPiA+
PiBhcmVhcyBzbyBJJ20gaGFwcHkgdG8gY2hhbmdlIHRoaXMgaWYgd2UgY2FuIHJlYWNoIHNvbWUg
Y29uc2Vuc3VzIG9uIHRoZQ0KPiA+PiBmb3JtYXQuDQo+ID4+DQo+ID5vaywgdGhhbmtzIGZvciB0
aGUgaGlzdG9yeS4geWVzLCB0aGV5IGRvIGxpZSBpbiBhIHdlaXJkIHNwb3QuDQo+IA0KPiBUaGV5
IGFyZSBsMiBhZGRyZXNzZXMsIHRoZXkgc2hvdWxkIGJlIHRocmVhdGVkIGFjY29yZGluZ2x5LiBB
bSBJIG1pc3NpbmcNCj4gc29tZXRoaW5nPw0KDQpJbiBsb29raW5nIHRvIHJld29yayB0aGlzIEkg
cmVtZW1iZXJlZCBzb21ldGhpbmcuIE9uZSBvZiB0aGUgcGx1cyBzaWRlcw0Kb2YgdXNpbmcgdGhl
IEFERFIgbWVzc2FnZXMgdG8gYXNzb2NpYXRlIGFkZHJlc3NlcyB3aXRoIHRoZSBkZXZpY2UgaXMN
CnRoYXQgd2UgY2FuIHVzZSB0aGUgTkVXL0RFTEFERFIgbWVzc2FnZXMgdG8gc2lnbmlmeSB0aGUg
YWRkaXRpb24gYW5kDQpkZWxldGlvbiBvZiB0aGVzZSBhZGRyZXNzZXMgaW5kaXZpZHVhbGx5IGFz
IHRoZXkgY29tZSBhbmQgZ28sIHdoaWNoIHRoZXkNCmRvIGFsbCB0aGUgdGltZSBlLmcgd2l0aCBJ
R01QIGpvaW5zIGFuZCBsZWF2ZXMuIElmIHdlIGVtYmVkIHRoZXNlDQphZGRyZXNzZXMgd2l0aGlu
IHRoZSBMSU5LIG1lc3NhZ2Ugd2UgY2Fubm90IHVzZSBORVdMSU5LIGFuZCBERUxMSU5LIHRvDQph
ZGQgYW5kIHJlbW92ZSBpbmRpdmlkdWFsIGFkZHJlc3NlcyBhcyB0aGF0IHdvdWxkIHNpZ25pZnkg
dGhlIGxpbmsNCmNvbWluZyBhbmQgZ29pbmcgd2hpY2ggaXMgbm90IHRoZSBjYXNlLiBTRVRMSU5L
IG1pZ2h0IHdvcmsgYnV0IHRoZW4gdGhlDQpvbnVzIGlzIG9uIHRoZSBuZXRsaW5rIGNsaWVudCB0
byBiZSBhYmxlIHRvIHdvcmsgb3V0IHRoZSBhZGRyZXNzDQphZGRpdGlvbnMvZGVsZXRpb25zIGJh
c2VkIG9uIGl0J3Mgb3duIHN0YXRlLiAgDQoNCj4gDQo+ID50aGUgZ2VuZXJhbCBjb252ZW50aW9u
IGZvciBvdGhlciBydG5sIHJlZ2lzdHJhdGlvbnMgc2VlbXMgdG8gYmUNCj4gPkFGX1VOU1BFQyBm
YW1pbHkgbWVhbnMgaW5jbHVkZSBhbGwgc3VwcG9ydGVkIGZhbWlsaWVzLiB0aGF0cyB3aGVyZSB0
aGlzIHNlZW1zIGEgYml0IG9kZC4NCj4gPg0KPiA+T24gdGhlIG90aGVyIGhhbmQsIG9uZSByZWFz
b24gSSBzZWUgd2hlcmUgdXNpbmcgUlRNXypBRERSIHdpbGwgYmUgdXNlZnVsIGZvciB0aGlzIGlz
IGlmIHdlIHdhbnRlZA0KPiA+dG8gcHJvdmlkZSBhIHdheSB0byBhZGQgdGhlc2UgdWMgYW5kIG1j
IGFkZHJlc3MgdmlhIGlwIGFkZHIgYWRkIGluIHRoZSBmdXR1cmUuDQo+ID5pcCBhZGRyIGFkZCA8
bGxhZGRyPiBkZXYgZXRoMA0KPiA+DQo+ID5Eb2VzIHRoaXMgcGF0Y2ggYWxsb3cgdGhhdCBpbiB0
aGUgZnV0dXJlID8NCj4gDQo+IFRoaXMgc2hvdWwgZ28gdW5kZXIgaXAgbGluayBJIGJlbGlldmUu
ICJpcCBhZGRyIiBpcyBmb3IgbDMuDQo+IA0KPiANCj4gPg0KPiA+YWxzbywgd2lsbCB0aGVzZSBs
MiBhZGRyZXNzZXMgbm93IHNob3cgdXAgaW4gJ2lwIGFkZHIgc2hvdycgb3V0cHV0ID8uDQo+ID4N
CkkgdGhpbmsgdGhlIHVzIG9uZXMgd2lsbCBkaXNwbGF5IGluIGlwIGFkZHIgc2hvdyBhbmQgdGhl
IG11dGxpY2FzdCBvbmVzDQppbiBpcCBtYWRkciBzaG93IC0gdGhpcyBpcyB0aGUgY2FzZSB0b2Rh
eSAoaS5lLiB3aXRob3V0IG15IGNoYW5nZXMpDQoNCnRoYW5rcw0KDQotcHINCg==
