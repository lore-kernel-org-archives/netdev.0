From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 20:49:42 +0000
Message-ID: <05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
	<1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
	<ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<52B33EC1.5040901@redhat.com>
	<6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogVG9tIEhlcmJlcnQgW21h
aWx0bzp0aGVyYmVydEBnb29nbGUuY29tXQ0KPiBTZW50OiBUaHVyc2RheSwgRGVjZW1iZXIgMTks
IDIwMTMgMjo1OSBQTQ0KPiBUbzogSGFpeWFuZyBaaGFuZw0KPiBDYzogRGFuaWVsIEJvcmttYW5u
OyBCZW4gSHV0Y2hpbmdzOyBkYXZlbUBkYXZlbWxvZnQubmV0Ow0KPiBuZXRkZXZAdmdlci5rZXJu
ZWwub3JnOyBLWSBTcmluaXZhc2FuOyBvbGFmQGFlcGZsZS5kZTsNCj4gamFzb3dhbmdAcmVkaGF0
LmNvbTsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgZHJpdmVyZGV2LQ0KPiBkZXZlbEBs
aW51eGRyaXZlcnByb2plY3Qub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIGh5
cGVydjogQWRkIHN1cHBvcnQgZm9yIFZpcnR1YWwgUmVjZWl2ZSBTaWRlDQo+IFNjYWxpbmcgKHZS
U1MpDQo+IA0KPiBJIHBvc3RlZCBhbiBpbXBsZW1lbnRhdGlvbiBvZiBsaWJyYXJ5IGZ1bmN0aW9u
cyBmb3IgVG9lcGxpdHogKHNlZSBbUEFUQ0ggMS8yXQ0KPiBuZXQ6IFRvZXBsaXR6IGxpYnJhcnkg
ZnVuY3Rpb25zKS4gIFRoaXMgaW5jbHVkZXMgc29tZSBwcmUtY29tcHV0YXRpb24gb2YgdGhlDQo+
IHRhYmxlIHRvIGdldCByZWFzb25hYmxlIHBlcmZvcm1hbmNlIGluIHRoZSBob3N0LiBQbGVhc2Ug
dGFrZSBhIGxvb2suDQo+IA0KPiBPbiB0aGUgb3RoZXIgaGFuZCwgaWYgeW91J3JlIGNvbXB1dGlu
ZyBhIGhhc2ggaW4gdGhlIGhvc3QsIGRvIHlvdSByZWFsbHkgbmVlZA0KPiBUb2VwbGl0eiwgZmxv
d19kaXNzZWN0b3IgYWxyZWFkeSBzdXBwb3J0cyBhIGdvb2QgaGFzaCBjb21wdXRhdGlvbiBhbmQg
Y2FuDQo+IHBhcnNlIG1hbnkgbW9yZSBwYWNrZXRzIHRoYW4ganVzdCBwbGFpbiBVRFAvVENQLg0K
PiBXZSBwcm9iYWJseSBvbmx5IHNob3VsZCBiZSBkb2luZyBUb2VwbGl0eiBpbiB0aGUgaG9zdCBp
ZiB3ZSBuZWVkIHRvIG1hdGNoDQo+IEhXIGNvbXB1dGVkIHZhbHVlcy4NCg0KVGhlIEh5cGVyLVYg
aG9zdCByZXF1aXJlcyB0aGUgZ3Vlc3QgdG8gc2VsZWN0IGNoYW5uZWwgYmFzZWQgb24gVG9lcGxp
dHogaGFzaCwgc28NCndlIG5lZWQgdG8gY29tcHV0ZSBpdCBvbiB0aGUgZ3Vlc3QuIA0KDQpSZWdh
cmRpbmcgdGhlIFRvZXBsaXR6IGZ1bmN0aW9uLCBkbyB5b3UgbWVhbiB0aGlzIHBhdGNoPw0KaHR0
cDovL3BhdGNod29yay5vemxhYnMub3JnL3BhdGNoLzI3NzM0NC8NClRoaXMgZG9lc24ndCBjb250
YWluIHRoZSBpbXBsZW1lbnRhdGlvbi4gQ291bGQgeW91IHBvaW50IG1lIHRvIHRoZSBhY3R1YWwg
Y29kZT8NCg0KVGhhbmtzLA0KLSBIYWl5YW5nDQoNCg==
