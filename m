From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: BUG in netxen_release_tx_buffers when TSO enabled on kernels >=
 3.3 and <= 3.6
Date: Wed, 23 Jan 2013 19:47:32 +0000
Message-ID: <C562D0E12CBDE44E8A0CCAB77060096705DE3B@AVMB1.qlogic.org>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
	 <1358861524.3464.3768.camel@edumazet-glaptop>
	 <1358862966.3464.3797.camel@edumazet-glaptop>
	 <1358883411.2892.11.camel@bwh-desktop.uk.solarflarecom.com>
 <1358884782.12374.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:32965
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750837Ab3AWTrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 14:47:43 -0500
In-Reply-To: <1358884782.12374.8.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86
ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj5TZW50OiBXZWRuZXNkYXksIEphbnVhcnkgMjMsIDIw
MTMgMTozMCBBTQ0KPlRvOiBCZW4gSHV0Y2hpbmdzDQo+Q2M6IGNocmlzdG9waC5wYWFzY2hAdWNs
b3V2YWluLmJlOyBJYW4gQ2FtcGJlbGw7IFNvbnkgQ2hhY2tvOyBSYWplc2gNCj5Cb3J1bmRpYTsg
RGF2aWQgTWlsbGVyOyBuZXRkZXYNCj5TdWJqZWN0OiBSZTogQlVHIGluIG5ldHhlbl9yZWxlYXNl
X3R4X2J1ZmZlcnMgd2hlbiBUU08gZW5hYmxlZCBvbg0KPmtlcm5lbHMgPj0gMy4zIGFuZCA8PSAz
LjYNCj4NCj5PbiBUdWUsIDIwMTMtMDEtMjIgYXQgMTk6MzYgKzAwMDAsIEJlbiBIdXRjaGluZ3Mg
d3JvdGU6DQo+DQo+PiBUaGVyZSdzIGFub3RoZXIgYnVnIHJpZ2h0IGhlcmUsIHdoaWNoIGlzIHRo
YXQgMCBpcyBhIHZhbGlkIERNQSBhZGRyZXNzDQo+PiBpbiBzb21lIHN5c3RlbXMuICBUaGUgZHJp
dmVyIHNob3VsZCBiZSBjYWxsaW5nIHBjaV9kbWFfbWFwcGluZ19lcnJvcigpDQo+PiB0byBmaW5k
IG91dCB3aGV0aGVyIGFuIGFkZHJlc3MgaXMgdmFsaWQgb3Igbm90LiAgQnV0IGl0IGFsc28gd2Fu
dHMgdG8NCj5iZQ0KPj4gYWJsZSB0byBhc3NpZ24gYW4gaW52YWxpZCBhZGRyZXNzIHRvIG5ldHhl
bl9za2JfZnJhZzo6ZG1hLCBhbmQNCj4+IHVuZm9ydHVuYXRlbHkgdGhlcmUgaXMgbm8gd2F5IHRv
IGRvIHRoYXQgaW4gdGhlIGN1cnJlbnQgRE1BIEFQSS4NCj4+DQo+DQo+SSBndWVzcyB3ZSBzaG91
bGQgb25seSB0ZXN0IC0+ZnJhZ19jb3VudCB0aGVuLCBhbmQgc2V0IGl0IHRvIDAgaW4gVFgNCj5j
b21wbGV0aW9uIHBhdGguDQo+DQpXZSB3aWxsIHNlbmQgYSBwYXRjaCB3aXRoIHRoZSBzdWdnZXN0
ZWQgZml4Lg0KDQo=
