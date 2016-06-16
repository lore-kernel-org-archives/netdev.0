From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net] ixgbe: napi_poll must return the work done
Date: Thu, 16 Jun 2016 17:43:18 +0000
Message-ID: <1466098998.17117.22.camel@intel.com>
References: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
	 <CAHdzE-8V8o9sg9xmiJ9J0G3u=k6K-fHQssb5v09TPJvN2N=a1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "hannes@redhat.com" <hannes@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "venkateshs@google.com" <venkateshs@google.com>,
	"pabeni@redhat.com" <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4119 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbcFPRnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 13:43:21 -0400
In-Reply-To: <CAHdzE-8V8o9sg9xmiJ9J0G3u=k6K-fHQssb5v09TPJvN2N=a1Q@mail.gmail.com>
Content-Language: en-US
Content-ID: <4A51E7281E41934F9B0D68DC2A615296@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE2LTA2LTE1IGF0IDA5OjM0IC0wNzAwLCBWZW5rYXRlc2ggU3Jpbml2YXMgd3Jv
dGU6DQo+IFJldmlld2VkLWJ5OiBWZW5rYXRlc2ggU3Jpbml2YXMgPHZlbmthdGVzaHNAZ29vZ2xl
LmNvbT4NCj4gDQo+IFRoZSBzYW1lIGJpdCBvZiBjb2RlIGFwcGVhcnMgaW4gZm0xMGsgYW5kIGk0
MGUvaTQwZXZmLiBpeGdiIGFwcGVhcnMNCj4gdG8NCj4gY29ycmVjdGx5IHJldHVybiB3b3JrX2Rv
bmUuDQo+IA0KPiBpeGdiZV9wb2xsIGFsc28gYXBwZWFycyB0byByZXR1cm4gYW7CoChtaW5vcikg
aW5jb3JyZWN0IHdvcmtfZG9uZSBpbg0KPiBhbm90aGVyIGNhc2UsIEJUVy4gSXQgZGl2aWRlcyBp
dHMNCj4gYnVkZ2V0IGJldHdlZW4gUnggcmluZ3MgYXNzb2NpYXRlZCB3aXRoIGEgdmVjdG9yLiBJ
ZiBhbnkgcmluZyBleGNlZWRzDQo+IGl0cyBzaGFyZSBvZiB0aGUgYnVkZ2V0LCBpeGdiZV9wb2xs
DQo+IGNsYWltcyB0byBoYXZlIGNvbnN1bWVkIHRoZSBmdWxsIGJ1ZGdldCwgZXZlbiBpZiBhIGZ1
bGwgYnVkZ2V0IG9mDQo+IGZyYW1lcyB3YXMgbm90IHJlY2VpdmVkIGluIGEgc2luZ2xlDQo+IHBh
c3MuDQo+IA0KDQpTbyB0aGUgY29ycmVjdCByZXR1cm4gaGVyZSB3b3VsZCBhbHNvIGJlIG1pbiBi
ZXR3ZWVuIHdvcmtfZG9uZSBhbmQNCmJ1ZGdldCwgcmlnaHQ/IGllOiB3ZSBzaG91bGQgc3RpbGwg
cmV0dXJuIHRoZSB0b3RhbCB3b3JrIGRvbmUgaW5zdGVhZA0Kb2YgdGhlIGJ1ZGdldC4uLj8NCg0K
VGhhbmtzLA0KSmFrZQ0KDQo+IC0tIHZzOw0K
