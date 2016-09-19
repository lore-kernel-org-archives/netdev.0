From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent
 channel counts.
Date: Mon, 19 Sep 2016 09:21:51 +0000
Message-ID: <BL2PR07MB23063DF1E02AA72ABE37DB4B8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
 <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
 <CACKFLikfTZYpmULGD5FvzixFRiCjqvQZxUKKquaaQ5qe9-PxuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:61120
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752711AbcISJyq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 05:54:46 -0400
In-Reply-To: <CACKFLikfTZYpmULGD5FvzixFRiCjqvQZxUKKquaaQ5qe9-PxuA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+PiBUaGUgZXhpc3RpbmcgY29kZSBpcyBpbmNvbnNpc3RlbnQgaW4gcmVwb3J0aW5nIGFuZCBh
Y2NlcHRpbmcgdGhlDQo+ID4+IGNvbWJpbmVkIGNoYW5uZWwgY291bnQuICBibnh0X2dldF9jaGFu
bmVscygpIHJlcG9ydHMgbWF4aW11bSBjb21iaW5lZA0KPiA+PiBhcyB0aGUgbWF4aW11bSByeCBj
b3VudC4gIGJueHRfc2V0X2NoYW5uZWxzKCkgYWNjZXB0cyBjb21iaW5lZCBjb3VudA0KPiA+PiB0
aGF0IGNhbm5vdCBiZSBiaWdnZXIgdGhhbiBtYXggcnggb3IgbWF4IHR4Lg0KPiA+Pg0KPiA+PiBG
b3IgZXhhbXBsZSwgaWYgbWF4IHJ4ID0gMiBhbmQgbWF4IHR4ID0gMSwgd2UgcmVwb3J0IG1heCBz
dXBwb3J0ZWQNCj4gPj4gY29tYmluZWQgdG8gYmUgMi4gIEJ1dCBpZiB0aGUgdXNlciB0cmllcyB0
byBzZXQgY29tYmluZWQgdG8gMiwgaXQNCj4gPj4gd2lsbCBmYWlsIGJlY2F1c2UgMiBpcyBiaWdn
ZXIgdGhhbiBtYXggdHggd2hpY2ggaXMgMS4NCj4gPj4NCj4gPj4gRml4IHRoZSBjb2RlIHRvIGJl
IGNvbnNpc3RlbnQuICBNYXggYWxsb3dlZCBjb21iaW5lZCA9IG1heChtYXhfcngsDQo+IG1heF90
eCkuDQo+ID4+IFdlIHdpbGwgYWNjZXB0IGEgY29tYmluZWQgY2hhbm5lbCBjb3VudCA8PSBtYXgo
bWF4X3J4LCBtYXhfdHgpLg0KPiA+DQo+ID4gRG9uJ3QgeW91IG1lYW4gdGhlICdtYXggYWxsb3dl
ZCBjb21iaW5lZCA9IG1pbihtYXhfcngsIG1heF90eCknLg0KPiA+IEhvdyBkb2VzIHVzaW5nICdt
YXgnIGNoYW5nZSB0aGUgZmF1bHR5IHNjZW5hcmlvIHlvdSd2ZSBkZXNjcmliZWQ/DQo+IA0KPiBJ
J20gZml4aW5nIHRoZSBpbmNvbnNpc3RlbmN5IGRlc2NyaWJlZCBpbiB0aGUgZmlyc3QgMiBwYXJh
Z3JhcGhzLiAgVGhlIGRyaXZlciBsb2dpYw0KPiBhbGxvd3MgYSBjb21iaW5lZCByaW5nIHRvIGJl
IHJ4IG9yIHR4IG9ubHkuICBJbiB0aGUgYWJvdmUgZXhhbXBsZSwgd2UgYWxsb3cNCj4gY29tYmlu
ZWQgdG8gYmUgc2V0IHRvIDIuICBUaGUgMm5kIGNvbWJpbmVkIHJpbmcgc3VwcG9ydHMgcnggb25s
eS4NCg0KVGhlbiB3aGF0IG1ha2VzIGl0IGEgY29tYmluZWQgY2hhbm5lbD8NClNvdW5kcyB0byBt
ZSBsaWtlIGluIHRoZSBhYm92ZSBzY2VuYXJpbyB5b3Ugc2hvdWxkIGhhdmUgY2xhaW1lZCBzdXBw
b3J0IGZvcjoNCiAgLSBtYXggcnggPT0gMg0KICAtIG1heCB0eCA9PSAxDQogIC0gbWF4IGNvbWJp
bmVkID09IDENCg==
