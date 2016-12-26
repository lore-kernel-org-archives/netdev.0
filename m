From: "Koteshwar Rao, Satha" <Satha.Rao@cavium.com>
Subject: RE: [RFC PATCH 1/7] PF driver modified to enable HW filter support,
 changes works in backward compatibility mode Enable required things in
 Makefile Enable LZ4 dependecy inside config file
Date: Mon, 26 Dec 2016 14:20:21 +0000
Message-ID: <DM5PR07MB28428EE7B1679FAEC78103AD8D960@DM5PR07MB2842.namprd07.prod.outlook.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
 <1482310011-1862-2-git-send-email-satha.rao@caviumnetworks.com>
 <CA+sq2CfwTN5u6nhxriqWqoFxsYHdEYikbjBgMCL2YwNXpqyQ=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
        "Goutham, Sunil" <Sunil.Goutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Daney, David" <David.Daney@cavium.com>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Romanov, Philip" <Philip.Romanov@cavium.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0048.outbound.protection.outlook.com ([104.47.32.48]:55199
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751894AbcLZOUq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Dec 2016 09:20:46 -0500
In-Reply-To: <CA+sq2CfwTN5u6nhxriqWqoFxsYHdEYikbjBgMCL2YwNXpqyQ=Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UmVzcG9uc2VzIGlubGluZQ0KDQpUaGFua3MsDQpTYXRoYQ0KDQotLS0tLU9yaWdpbmFsIE1lc3Nh
Z2UtLS0tLQ0KRnJvbTogU3VuaWwgS292dnVyaSBbbWFpbHRvOnN1bmlsLmtvdnZ1cmlAZ21haWwu
Y29tXSANClNlbnQ6IFdlZG5lc2RheSwgRGVjZW1iZXIgMjEsIDIwMTYgNTowNSBBTQ0KVG86IEtv
dGVzaHdhciBSYW8sIFNhdGhhDQpDYzogTEtNTDsgR291dGhhbSwgU3VuaWw7IFJvYmVydCBSaWNo
dGVyOyBEYXZpZCBTLiBNaWxsZXI7IERhbmV5LCBEYXZpZDsgVmF0c2F2YXlpLCBSYWdodTsgQ2hp
Y2tsZXMsIERlcmVrOyBSb21hbm92LCBQaGlsaXA7IExpbnV4IE5ldGRldiBMaXN0OyBMQUtNTA0K
U3ViamVjdDogUmU6IFtSRkMgUEFUQ0ggMS83XSBQRiBkcml2ZXIgbW9kaWZpZWQgdG8gZW5hYmxl
IEhXIGZpbHRlciBzdXBwb3J0LCBjaGFuZ2VzIHdvcmtzIGluIGJhY2t3YXJkIGNvbXBhdGliaWxp
dHkgbW9kZSBFbmFibGUgcmVxdWlyZWQgdGhpbmdzIGluIE1ha2VmaWxlIEVuYWJsZSBMWjQgZGVw
ZW5kZWN5IGluc2lkZSBjb25maWcgZmlsZQ0KDQo+DQo+ICAjZGVmaW5lIE5JQ19NQVhfUlNTX0hB
U0hfQklUUyAgICAgICAgICA4DQo+ICAjZGVmaW5lIE5JQ19NQVhfUlNTX0lEUl9UQkxfU0laRSAg
ICAgICAoMSA8PCBOSUNfTUFYX1JTU19IQVNIX0JJVFMpDQo+ICsjZGVmaW5lIE5JQ19UTlNfUlNT
X0lEUl9UQkxfU0laRSAgICAgICA1DQoNClNvIHlvdSB3YW50IHRvIHVzZSBvbmx5IDUgcXVldWVz
IHBlciBWRiB3aGVuIFROUyBpcyBlbmFibGVkLCBpcyBpdCA/Pw0KVGhlcmUgYXJlIDQwOTYgUlNT
IGluZGljZXMgaW4gdG90YWwsIGZvciBlYWNoIFZGIHlvdSBjYW4gdXNlIG1heCAzMi4NCkkgZ3Vl
c3MgeW91IHdhbnRlZCB0byBzZXQgbm8gb2YgaGFzaCBiaXRzIHRvIDUgaW5zdGVhZCBvZiB0YWJs
ZSBzaXplLg0KDQpTQVRIQT4+PiBXZSBlbmFibGVkIDggcXVldWVzIGZvciBWRi4gWWVzIE1hY3Jv
IG5hbWUgbWlzbGVhZHMgaXQgaGFzIHRvIGJlIGhhc2ggYml0cywgd2lsbCBjaGFuZ2UgdGhpcyBp
biBuZXh0IHZlcnNpb24NCg0KPiAgI2RlZmluZSBSU1NfSEFTSF9LRVlfU0laRSAgICAgICAgICAg
ICAgNSAvKiAzMjAgYml0IGtleSAqLw0KPg0KPiAgc3RydWN0IG5pY3ZmX3Jzc19pbmZvIHsNCj4g
QEAgLTI1NSw3NCArMjU4LDYgQEAgc3RydWN0IG5pY3ZmX2Rydl9zdGF0cyB7DQo+ICAgICAgICAg
c3RydWN0IHU2NF9zdGF0c19zeW5jICAgc3luY3A7DQo+ICB9Ow0KPg0KPiAtc3RydWN0IG5pY3Zm
IHsNCj4gLSAgICAgICBzdHJ1Y3QgbmljdmYgICAgICAgICAgICAqcG5pY3ZmOw0KPiAtICAgICAg
IHN0cnVjdCBuZXRfZGV2aWNlICAgICAgICpuZXRkZXY7DQo+IC0gICAgICAgc3RydWN0IHBjaV9k
ZXYgICAgICAgICAgKnBkZXY7DQo+IC0gICAgICAgdm9pZCBfX2lvbWVtICAgICAgICAgICAgKnJl
Z19iYXNlOw0KDQpEaWRuJ3QgZ2V0IHdoeSB5b3UgbW92ZWQgdGhpcyBzdHJ1Y3R1cmUgdG8gdGhl
IGVuZCBvZiBmaWxlLg0KTG9va3MgbGlrZSBhbiB1bm5lY2Vzc2FyeSBtb2RpZmljYXRpb24uDQpT
QVRIQT4+PiBQcmV2aW91c2x5IHdlIGhhdmUgc29tZSBkZXBlbmRlbmN5LCB3ZSBsb29rIGludG8g
dGhpcywgYW5kIGFkZHJlc3MgaW4gbmV4dCB2ZXJpc29uDQoNCj4gK3N0YXRpYyB1bnNpZ25lZCBp
bnQgbnVtX3ZmczsNCj4gK21vZHVsZV9wYXJhbShudW1fdmZzLCB1aW50LCAwNjQ0KTsNCj4gK01P
RFVMRV9QQVJNX0RFU0MobnVtX3ZmcywgIk5vbiB6ZXJvIHBvc2l0aXZlIHZhbHVlLCBzcGVjaWZp
ZXMgbnVtYmVyIA0KPiArb2YgVkYncyBwZXIgcGh5c2ljYWwgcG9ydCIpOw0KDQpTbyB3aGF0IGlm
IGRyaXZlciBpcyBidWlsdC1pbiBpbnN0ZWFkIG9mIG1vZHVsZSwgSSBjYW4ndCB1c2UgVE5TIGlz
IGl0ID8NClNBVEhBPj4+IFN0aWxsIHlvdSBjYW4gZW5hYmxlIHRoaXMgc3BlY2lhbCBmZWF0dXJl
cyBieSBwYXNzaW5nIGJvb3QgYXJndW1lbnQgIm5pY3BmLm51bV92ZnM9WCINCg0KPg0KPiArLyog
U2V0IFJCRFIgQmFja3ByZXNzdXJlIChSQkRSX0JQKSBhbmQgQ1EgYmFja3ByZXNzdXJlIChDUV9C
UCkgb2YgDQo+ICt2bmljIHF1ZXVlcw0KPiArICogdG8gMTI5IGVhY2gNCg0KV2h5IDEyOSA/Pw0K
UkJEUiBtaW5pbXVtIHNpemUgaXMgOEsgYnVmZmVycywgd2h5IHlvdSB3YW50IHRvIGFzc2VydCBC
UCB3aGVuIHN0aWxsIH40SyBidWZmZXJzIGFyZSBhdmFpbGFibGUuIElzbid0IDRLIGEgaHVnZSBu
dW1iZXIgdG8gc3RhcnQgYXNzZXJ0aW5nIGJhY2twcmVzc3VyZSA/DQpTQVRIQT4+PiBBcyBDUSBj
b3VudCB3YXMgNEsgZW50cmllcywgSSB1c2VkIHNhbWUgQlAgdmFsdWUgZm9yIGJvdGgsIHdpbGwg
YWRkcmVzcyB0aGlzIGluIG5leHQgdmVyc2lvbg0K
