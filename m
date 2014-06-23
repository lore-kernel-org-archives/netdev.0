From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 23 Jun 2014 09:18:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726087E@AcuExch.aculab.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
	<CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
	<538CAEA6.4060307@redhat.com>
	<CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
	<538D8DAA.7090105@redhat.com>
	<CAMEtUuw8uyCGeLeUB0PXm5cCpqcsjPLZt6y9FcKjapbVPjWTuw@mail.gmail.com>
	<538E319B.3000606@redhat.com>
	<CAMEtUuzsHJioXZtuGje6UmwZmcmDZEn8PdkkYanA9j1sp242+Q@mail.gmail.com>
	<CA+ZOOTOfq705CbUjx9ppw4gLxJ8JFCaFsphwhAS+NskHVjd86Q@mail.gmail.com>
	<CAMEtUuxU_FKL4TJ2wJtOngean2RjjJxBbYpxNjJQKjA7HtU2Bg@mail.gmail.com>
 <CA+ZOOTOjRmj-C0tncH=j4ZJj8aMMVF1RLK-gQiSB6RG=G5Xo7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	"Jiri Olsa" <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: 'Chema Gonzalez' <chema@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ZOOTOjRmj-C0tncH=j4ZJj8aMMVF1RLK-gQiSB6RG=G5Xo7w@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQ2hlbWEgR29uemFsZXoNCi4uLg0KPiA0LjUuIEJQRl9TVHxCUEZfTUVNDQo+IE9wZXJh
dGlvbjogKihzaXplICopIChkc3RfcmVnICsgb2ZmMTYpID0gaW1tMzINCj4gDQo+IFRoaXMgaW5z
biBlbmNvZGVzIDIgaW1tZWRpYXRlIHZhbHVlcyAodGhlIG9mZnNldCBhbmQgdGhlIGltbTMyIHZh
bHVlKQ0KPiBpbiB0aGUgaW5zbiwgYW5kIGFjdHVhbGx5IGZvcmNlcyB0aGUgc29ja19maWx0ZXJf
aW50IDY0LWJpdCBzdHJ1Y3QgdG8NCj4gaGF2ZSBib3RoIGEgMTYtYml0IG9mZnNldCBmaWVsZCBh
bmQgYSAzMi1iaXQgaW1tZWRpYXRlIGZpZWxkKS4gSW4NCj4gZmFjdCwgaXQncyB0aGUgb25seSBp
bnN0cnVjdGlvbnMgdGhhdCB1c2VzIC5vZmYgYW5kIC5pbW0gYXQgdGhlIHNhbWUNCj4gdGltZSAo
Zm9yIGFsbCBvdGhlciBpbnN0cnVjdGlvbnMsIGF0IGxlYXN0IG9uZSBvZiB0aGUgZmllbGRzIGlz
IGFsd2F5cw0KPiAwKS4NCj4gDQo+IFRoaXMgZGlkIG5vdCBleGlzdCBpbiBjbGFzc2ljIEJQRiAo
d2hlcmUgQlBGX1NUfEJQRl9NRU0gYWN0dWFsbHkgZGlkDQo+ICJtZW1bcGMtPmtdID0gQTsiKS4g
SW4gZmFjdCwgaXQncyByYXJlIHRvIGZpbmQgYW4gSVNBIHRoYXQgYWxsb3dzDQo+IGVuY29kaW5n
IDIgaW1tZWRpYXRlIHZhbHVlcyBpbiBhIHNpbmdsZSBpbnNuLiBNeSBpbXByZXNzaW9uIChhZnRl
cg0KPiBjaGVja2luZyB0aGUgeDg2IEpJVCBpbXBsZW1lbnRhdGlvbiwgd2hpY2ggd29ya3Mgb24g
dGhlIGVCUEYgY29kZSkgaXMNCj4gdGhhdCB0aGlzIHdhcyBhZGRlZCBhcyBhbiB4ODYgb3B0aW1p
emF0aW9uLCBiZWNhdXNlIHg4NiBhbGxvd3MNCj4gZW5jb2RpbmcgMiB2YWx1ZXMgKG9mZnNldCBh
bmQgaW1tZWRpYXRlKSBieSB1c2luZyB0aGUgZGlzcGxhY2VtZW50IGFuZA0KPiBpbW1lZGlhdGUg
c3VmZml4ZXMuIEkgd29uZGVyIHdoZXRoZXIgdGhlIElTQSB3b3VsZCBiZSBtb3JlIHJlYWRhYmxl
IGlmDQo+IHdlIGRpZCB0aGlzIGluIDIgaW5zbiwgb25lIHRvIHB1dCBkc3RfcmVnK29mZjE2IGlu
IGEgdGVtcG9yYXJ5DQo+IHJlZ2lzdGVyLCBhbmQgdGhlIHNlY29uZCBhIHNpbXBsZXIgQlBGX1NU
WHxCUEZfTUVNLiBUaGVuIHdlIGNvdWxkIHVzZQ0KPiB0aGUgc2FtZSBzcGFjZSBmb3IgdGhlIGlt
bWVkaWF0ZSBhbmQgb2Zmc2V0IGZpZWxkcy4NCg0KT25lIG9wdGlvbiBpcyB0byBhZGQgY29kZSB0
byB0aGUgeDg2IEpJVCB0byBkZXRlY3QgdGhlIHR3byBpbnN0cnVjdGlvbg0Kc2VxdWVuY2UgYW5k
IGdlbmVyYXRlIGEgc2luZ2xlIGluc3RydWN0aW9uLg0KDQpUaGlua3MgZnVydGhlciwgdGhlIEpJ
VCBtaWdodCBiZSBlYXNpZXIgdG8gd3JpdGUgaWYgdGhlcmUgaXMgYSB0ZW1wb3JhcnkNCnJlZ2lz
dGVyIHRoYXQgaXMgZGVmaW5lZCB0byBiZSBvbmx5IHZhbGlkIGZvciB0aGUgbmV4dCBpbnN0cnVj
dGlvbiAob3IgdHdvKS4NClRoZW4gdGhlIEpJVCBjYW4gY29tcGxldGVseSBvcHRpbWlzZSBhd2F5
IGFueSBhc3NpZ25tZW50cyB0byBpdCB3aXRob3V0DQpyZXF1aXJpbmcgYSBmdWxsIGFuYWx5c2lz
IG9mIHRoZSBlbnRpcmUgcHJvZ3JhbS4NCg0KCURhdmlkDQoNCg==
