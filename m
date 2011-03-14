From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 3/6] can: make struct proto const
Date: Mon, 14 Mar 2011 16:02:27 +0100
Message-ID: <20110314150227.GJ333@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314134721.GD333@e-circ.dyndns.org>
	<1300111755.3423.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1300111755.3423.20.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gTW9uLCBNYXIgMTQsIDIwMTEgYXQgMDM6MDk6MTVQTSArMDEwMCwgRXJpYyBEdW1hemV0IHdy
b3RlOgo+IExlIGx1bmRpIDE0IG1hcnMgMjAxMSDDoCAxNDo0NyArMDEwMCwgS3VydCBWYW4gRGlq
Y2sgYSDDqWNyaXQgOgo+ID4gY2FuX2lvY3RsIGlzIHRoZSBvbmx5IHJlYXNvbiBmb3Igc3RydWN0
IHByb3RvIHRvIGJlIG5vbi1jb25zdC4KPiA+IHNjcmlwdC9jaGVjay1wYXRjaC5wbCBzdWdnZXN0
cyBzdHJ1Y3QgcHJvdG8gYmUgY29uc3QuCj4gPiBUaGlzIHBhdGNoIHBlcmZvcm1zIHRoZSBuZWNl
c3NhcnkgY2hhbmdlLgo+ID4gCj4gPiAgc3RhdGljIHZvaWQgY2FuX3NvY2tfZGVzdHJ1Y3Qoc3Ry
dWN0IHNvY2sgKnNrKQo+ID4gIHsKPiA+IEBAIC03MjAsMTAgKzcyMSw2IEBAIGludCBjYW5fcHJv
dG9fcmVnaXN0ZXIoY29uc3Qgc3RydWN0IGNhbl9wcm90byAqY3ApCj4gPiAgCQllcnIgPSAtRUJV
U1k7Cj4gPiAgCX0gZWxzZSB7Cj4gPiAgCQlwcm90b190YWJbcHJvdG9dID0gY3A7Cj4gPiAtCj4g
PiAtCQkvKiB1c2UgZ2VuZXJpYyBpb2N0bCBmdW5jdGlvbiBpZiBub3QgZGVmaW5lZCBieSBtb2R1
bGUgKi8KPiA+IC0JCWlmICghY3AtPm9wcy0+aW9jdGwpCj4gPiAtCQkJY3AtPm9wcy0+aW9jdGwg
PSBjYW5faW9jdGw7Cj4gCj4gSG1tLCB5b3UgYWN0dWFsbHkgZml4ZWQgYSByYWNlIC8gYnVnLCBz
aW5jZSB3ZSBpbnN0YWxsZWQgaW4gcHJvdG9fdGFiW10KPiBhIHBvaW50ZXIgdG8gYSBub3QgeWV0
IGluaXR0ZWQgb3BzIHN0cnVjdHVyZS4KSSBzZWUgeW91ciBwb2ludC4KVGhlIHJlYXNvbiBJIG1v
ZGlmaWVkIHRoaXMgd2FzLCBhcyBkZXNjcmliZWQsIGNoZWNrcGF0Y2gucGwgd2FzIGNvbXBsYWlu
aW5nLgpBbnl3YXksIHRoaXMgc2VxdWVuY2Ugd2FzIHByb3RlY3RlZCBieSBhIHNwaW5sb2NrICdw
cm90b190YWJfbG9jaycuCkkgZG9uJ3QgdGhpbmsgaXQgd2FzIGEgcmFjZS4KCkRpZCBJIG1pc3Mg
c29tZXRoaW5nPwpLdXJ0Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fClNvY2tldGNhbi1jb3JlIG1haWxpbmcgbGlzdApTb2NrZXRjYW4tY29yZUBsaXN0cy5i
ZXJsaW9zLmRlCmh0dHBzOi8vbGlzdHMuYmVybGlvcy5kZS9tYWlsbWFuL2xpc3RpbmZvL3NvY2tl
dGNhbi1jb3JlCg==
