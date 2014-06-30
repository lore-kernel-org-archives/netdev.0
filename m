From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 07/14] bpf: expand BPF syscall with program
 load/unload
Date: Mon, 30 Jun 2014 10:06:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17269505@AcuExch.aculab.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-8-git-send-email-ast@plumgrid.com>
	<CALCETrXDR1LVmbigTicBiddgvcucM1dGk1R7rxdJyBCvGEBQMw@mail.gmail.com>
 <CAMEtUuywNHVcZ__296NzXK7RPXUBOf7gNQY9JFx0a9PV0Se+wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	"Jiri Olsa" <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuywNHVcZ__296NzXK7RPXUBOf7gNQY9JFx0a9PV0Se+wA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92DQo+IE9uIEZyaSwgSnVuIDI3LCAyMDE0IGF0IDU6MTkg
UE0sIEFuZHkgTHV0b21pcnNraSA8bHV0b0BhbWFjYXBpdGFsLm5ldD4gd3JvdGU6DQo+ID4gT24g
RnJpLCBKdW4gMjcsIDIwMTQgYXQgNTowNSBQTSwgQWxleGVpIFN0YXJvdm9pdG92IDxhc3RAcGx1
bWdyaWQuY29tPiB3cm90ZToNCj4gPj4gZUJQRiBwcm9ncmFtcyBhcmUgc2FmZSBydW4tdG8tY29t
cGxldGlvbiBmdW5jdGlvbnMgd2l0aCBsb2FkL3VubG9hZA0KPiA+PiBtZXRob2RzIGZyb20gdXNl
cnNwYWNlIHNpbWlsYXIgdG8ga2VybmVsIG1vZHVsZXMuDQo+ID4+DQo+ID4+IFVzZXIgc3BhY2Ug
QVBJOg0KPiA+Pg0KPiA+PiAtIGxvYWQgZUJQRiBwcm9ncmFtDQo+ID4+ICAgcHJvZ19pZCA9IGJw
Zl9wcm9nX2xvYWQoaW50IHByb2dfaWQsIGJwZl9wcm9nX3R5cGUsIHN0cnVjdCBubGF0dHIgKnBy
b2csIGludCBsZW4pDQo+ID4+DQo+ID4+ICAgd2hlcmUgJ3Byb2cnIGlzIGEgc2VxdWVuY2Ugb2Yg
c2VjdGlvbnMgKGN1cnJlbnRseSBURVhUIGFuZCBMSUNFTlNFKQ0KPiA+PiAgIFRFWFQgLSBhcnJh
eSBvZiBlQlBGIGluc3RydWN0aW9ucw0KPiA+PiAgIExJQ0VOU0UgLSBHUEwgY29tcGF0aWJsZQ0K
PiA+PiArDQo+ID4+ICsgICAgICAgZXJyID0gLUVJTlZBTDsNCj4gPj4gKyAgICAgICAvKiBsb29r
IGZvciBtYW5kYXRvcnkgbGljZW5zZSBzdHJpbmcgKi8NCj4gPj4gKyAgICAgICBpZiAoIXRiW0JQ
Rl9QUk9HX0xJQ0VOU0VdKQ0KPiA+PiArICAgICAgICAgICAgICAgZ290byBmcmVlX2F0dHI7DQo+
ID4+ICsNCj4gPj4gKyAgICAgICAvKiBlQlBGIHByb2dyYW1zIG11c3QgYmUgR1BMIGNvbXBhdGli
bGUgKi8NCj4gPj4gKyAgICAgICBpZiAoIWxpY2Vuc2VfaXNfZ3BsX2NvbXBhdGlibGUobmxhX2Rh
dGEodGJbQlBGX1BST0dfTElDRU5TRV0pKSkNCj4gPj4gKyAgICAgICAgICAgICAgIGdvdG8gZnJl
ZV9hdHRyOw0KPiA+DQo+ID4gU2VyaW91c2x5PyAgTXkgbWluZCBib2dnbGVzLg0KPiANCj4gWWVz
LiBRdWl0ZSBhIGJpdCBvZiBsb2dpYyBjYW4gZml0IGludG8gb25lIGVCUEYgcHJvZ3JhbS4gSSBk
b24ndCB0aGluayBpdCdzIHdpc2UNCj4gdG8gbGVhdmUgdGhpcyBkb29yIG9wZW4gZm9yIGFidXNl
LiBUaGlzIGNoZWNrIG1ha2VzIGl0IGNsZWFyIHRoYXQgaWYgeW91DQo+IHdyaXRlIGEgcHJvZ3Jh
bSBpbiBDLCB0aGUgc291cmNlIGNvZGUgbXVzdCBiZSBhdmFpbGFibGUuDQoNClRoYXQgc2VlbXMg
dXR0ZXJseSBleHRyZW1lLg0KTG9hZGFibGUga2VybmVsIG1vZHVsZXMgZG9uJ3QgaGF2ZSB0byBi
ZSBHUEwuDQoNCkkgY2FuIGltYWdpbmUgdGhhdCBzb21lIHBlb3BsZSBtaWdodCBub3Qgd2FudCB0
byBsb2FkIGNvZGUgZm9yIHdoaWNoDQp0aGV5IGRvbid0IGhhdmUgdGhlIHNvdXJjZSAtIGJ1dCBp
biB0aGF0IGNhc2UgdGhleSBwcm9iYWJseSB3YW50IHRvDQpjb21waWxlIGl0IHRoZW1zZWx2ZXMg
YW55d2F5Lg0KDQpJIGRvbid0IHdhbnQgdG8gaGF2ZSB0byBwdXQgYSBncGwgbGljZW5jZSBvbiBy
YW5kb20gcGllY2VzIG9mIHRlc3QNCmNvZGUgSSBtaWdodCBoYXBwZW4gdG8gd3JpdGUgZm9yIG15
IG93biB1c2UuDQoNCglEYXZpZA0KDQo=
