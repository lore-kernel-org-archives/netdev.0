From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 23 Sep 2011 08:11:03 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
	 <1316762872.23371.88.camel@zakaz.uk.xensource.com>
	 <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Ian Campbell <ijc@hellion.org.uk>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1316790220.23371.105.camel@zakaz.uk.xensource.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwgW21haWx0
bzppamNAaGVsbGlvbi5vcmcudWtdDQo+IFNlbnQ6IEZyaWRheSwgU2VwdGVtYmVyIDIzLCAyMDEx
IDg6MDQgQU0NCj4gVG86IFJvc2UsIEdyZWdvcnkgVg0KPiBDYzogS2lyc2hlciwgSmVmZnJleSBU
OyBkYXZlbUBkYXZlbWxvZnQubmV0OyBrb25yYWQud2lsa0BvcmFjbGUuY29tOyBKZXNzZQ0KPiBC
YXJuZXM7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGdvc3BvQHJlZGhhdC5jb207IGxpbnV4LQ0K
PiBwY2lAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJFOiBbbmV0LW5leHQgMS84XSBwY2k6
IEFkZCBmbGFnIGluZGljYXRpbmcgZGV2aWNlIGhhcyBiZWVuDQo+IGFzc2lnbmVkIGJ5IEtWTQ0K
PiANCj4gT24gRnJpLCAyMDExLTA5LTIzIGF0IDA3OjQxIC0wNzAwLCBSb3NlLCBHcmVnb3J5IFYg
d3JvdGU6DQo+ID4gPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiA+ID4gRnJvbTogSWFu
IENhbXBiZWxsIFttYWlsdG86aWpjQGhlbGxpb24ub3JnLnVrXQ0KPiA+ID4gU2VudDogRnJpZGF5
LCBTZXB0ZW1iZXIgMjMsIDIwMTEgMTI6MjggQU0NCj4gPiA+IFRvOiBLaXJzaGVyLCBKZWZmcmV5
IFQNCj4gPiA+IENjOiBkYXZlbUBkYXZlbWxvZnQubmV0OyBrb25yYWQud2lsa0BvcmFjbGUuY29t
OyBKZXNzZSBCYXJuZXM7IFJvc2UsDQo+ID4gPiBHcmVnb3J5IFY7IG5ldGRldkB2Z2VyLmtlcm5l
bC5vcmc7IGdvc3BvQHJlZGhhdC5jb207IGxpbnV4LQ0KPiA+ID4gcGNpQHZnZXIua2VybmVsLm9y
Zw0KPiA+ID4gU3ViamVjdDogUmU6IFtuZXQtbmV4dCAxLzhdIHBjaTogQWRkIGZsYWcgaW5kaWNh
dGluZyBkZXZpY2UgaGFzIGJlZW4NCj4gPiA+IGFzc2lnbmVkIGJ5IEtWTQ0KPiA+ID4NCj4gPiA+
IEkgc3VwcG9zZSBieSB0aGF0IG1lYXN1cmUgdGhlIGNvbW1lbnQgY291bGQgYmUgbGVzcyBLVk0g
c3BlY2lmaWM6DQo+ID4gPiA+ICsgICAgICAgLyogUHJvdmlkZSBpbmRpY2F0aW9uIGRldmljZSBp
cyBhc3NpZ25lZCBieSBLVk0gKi8NCj4gPiA+ID4gKyAgICAgICBQQ0lfREVWX0ZMQUdTX0FTU0lH
TkVEID0gKF9fZm9yY2UgcGNpX2Rldl9mbGFnc190KSA0LA0KPiA+DQo+ID4gV2UgY2FuIHJlc3Vi
bWl0IHdpdGggYSBtb3JlIGdlbmVyaWMgY29tbWVudCwgbWF5YmUgdGhpczoNCj4gPg0KPiA+IC8q
IFByb3ZpZGUgaW5kaWNhdGlvbiBkZXZpY2UgaXMgYXNzaWduZWQgYnkgYSBWaXJ0dWFsIE1hY2hp
bmUgTWFuYWdlciAqLw0KPiANCj4gU291bmRzIGdvb2QgdG8gbWUuDQoNCkRhdmUsIEplZmYsDQoN
ClNob3VsZCBJIHJlc3VibWl0IHRoZSBwYXRjaCBvciB3b3VsZCBpdCBiZSBtb3JlIGNvbnZlbmll
bnQgdG8gcG9zdCBhIGZvbGxvdyBvbiBwYXRjaCB0aGF0IGZpeGVzIHVwIHRoZSBjb21tZW50PyAg
RWl0aGVyIHdheSBpcyBmaW5lIGJ5IG1lLg0KDQotIEdyZWcNCg0K
