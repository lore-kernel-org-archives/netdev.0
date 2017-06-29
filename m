From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next v4 04/16] bpf: Sample bpf program to set
 SYN/SYN-ACK RTOs
Date: Thu, 29 Jun 2017 22:25:36 +0000
Message-ID: <43F29BF4-8847-47AC-AE0F-9FC9410B7D5C@fb.com>
References: <20170628173124.3299500-1-brakmo@fb.com>
 <20170628173124.3299500-5-brakmo@fb.com> <20170629213914.0c0c5c2b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        "Blake Matheny" <bmatheny@fb.com>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37269 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751804AbdF2WZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 18:25:58 -0400
In-Reply-To: <20170629213914.0c0c5c2b@redhat.com>
Content-Language: en-US
Content-ID: <DCF1F4CCD8F09749A5FBFBE98D5DC206@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpPbiA2LzI5LzE3LCAxMjozOSBQTSwgIm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmcgb24g
YmVoYWxmIG9mIEplc3BlciBEYW5nYWFyZCBCcm91ZXIiIDxuZXRkZXYtb3duZXJAdmdlci5rZXJu
ZWwub3JnIG9uIGJlaGFsZiBvZiBicm91ZXJAcmVkaGF0LmNvbT4gd3JvdGU6DQoNCiAgICBPbiBX
ZWQsIDI4IEp1biAyMDE3IDEwOjMxOjEyIC0wNzAwDQogICAgTGF3cmVuY2UgQnJha21vIDxicmFr
bW9AZmIuY29tPiB3cm90ZToNCiAgICANCiAgICA+ICsrKyBiL3NhbXBsZXMvYnBmL3RjcF9zeW5y
dG9fa2Vybi5jDQogICAgPiBAQCAtMCwwICsxLDYwIEBADQogICAgPiArLyogQ29weXJpZ2h0IChj
KSAyMDE3IEZhY2Vib29rDQogICAgPiArICoNCiAgICA+ICsgKiBUaGlzIHByb2dyYW0gaXMgZnJl
ZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yDQogICAgPiArICogbW9k
aWZ5IGl0IHVuZGVyIHRoZSB0ZXJtcyBvZiB2ZXJzaW9uIDIgb2YgdGhlIEdOVSBHZW5lcmFsIFB1
YmxpYw0KICAgID4gKyAqIExpY2Vuc2UgYXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJl
IEZvdW5kYXRpb24uDQogICAgPiArICoNCiAgICA+ICsgKiBCUEYgcHJvZ3JhbSB0byBzZXQgU1lO
IGFuZCBTWU4tQUNLIFJUT3MgdG8gMTBtcyB3aGVuIHVzaW5nIElQdjYgYWRkcmVzc2VzDQogICAg
PiArICogYW5kIHRoZSBmaXJzdCA1LjUgYnl0ZXMgb2YgdGhlIElQdjYgYWRkcmVzc2VzIGFyZSB0
aGUgc2FtZSAoaW4gdGhpcyBleGFtcGxlDQogICAgPiArICogdGhhdCBtZWFucyBib3RoIGhvc3Rz
IGFyZSBpbiB0aGUgc2FtZSBkYXRhY2VudGVyLg0KICAgIA0KICAgIE1pc3NpbmcgZW5kICIpIi4N
CiAgICANCiAgICBJIHJlYWxseSBsaWtlIHRoaXMgc2hvcnQgY29tbWVudCBvZiB3aGF0IHRoZSBw
cm9ncmFtIGRvZXMsIGFzIGl0IGhlbHBzDQogICAgcGVvcGxlIGJyb3dzaW5nIHRoZXNlIHNhbXBs
ZSBwcm9ncmFtcy4gDQogICAgDQogICAgQ2FuIHlvdSBhbHNvIG1lbnRpb24gaW4gdGhlIGNvbW1l
bnQgKG9mIGFsbCB0aGVzZSkgYnBmIHByb2dyYW1zIHRoYXQNCiAgICBwZW9wbGUgbG9hZCB0aGlz
IGJwZiBvYmplY3QgZmlsZSB2aWEgdGhlIHByb2dyYW0gJ2xvYWRfc29ja19vcHMnPw0KDQpUaGFu
ayB5b3UgZm9yIGZpbmRpbmcgdGhlIHR5cG8gYW5kIGZvciB0aGUgY29tbWVudCBvbiBhZGRpbmcg
aG93IHRvIGxvYWQgdGhlIHNhbXBsZSBwcm9ncmFtcy4gV2lsbCBiZSBkb25lIGluIHY1IGR1ZSBs
YXRlciB0b2RheS4NCiAgICANCiAgICAtLSANCiAgICBCZXN0IHJlZ2FyZHMsDQogICAgICBKZXNw
ZXIgRGFuZ2FhcmQgQnJvdWVyDQogICAgICBNU2MuQ1MsIFByaW5jaXBhbCBLZXJuZWwgRW5naW5l
ZXIgYXQgUmVkIEhhdA0KICAgICAgTGlua2VkSW46IGh0dHBzOi8vdXJsZGVmZW5zZS5wcm9vZnBv
aW50LmNvbS92Mi91cmw/dT1odHRwLTNBX193d3cubGlua2VkaW4uY29tX2luX2Jyb3VlciZkPUR3
SUNBZyZjPTVWRDBSVHRObFRoM3ljZDQxYjNNVXcmcj1wcV9NcXZ6ZnktQzhsdGtneXgxdV9nJm09
RUoxVHlhbkNHRU9JWEVQbkFtOEJpY1ZqVVhFSkxzdlVRWTF2TkNfNHI3ZyZzPUlOY2RULW1pbWhP
WkVnRkx3N2hxZzJWNlZKNzBYWkpvZVk4M3ZwNlY4WVkmZT0gDQogICAgDQoNCg==
