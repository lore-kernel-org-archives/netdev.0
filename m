From: roopa <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [RFC net-next 03/22] ipv4: support for fib route
 lwtunnel encap attributes
Date: Fri, 10 Jul 2015 09:56:56 -0700
Message-ID: <559FF958.1020403@cumulusnetworks.com>
References: <cover.1436537414.git.tgraf@suug.ch>
 <8ebc9066754f07003d54c3ac64d8c46f9c1c570b.1436537414.git.tgraf@suug.ch>
 <1436542616.24939.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150710165436.GC11654@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20150710165436.GC11654-4EA/1caXOu0mYvmMESoHnA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gNy8xMC8xNSwgOTo1NCBBTSwgVGhvbWFzIEdyYWYgd3JvdGU6Cj4gT24gMDcvMTAvMTUgYXQg
MDU6MzZwbSwgRXJpYyBEdW1hemV0IHdyb3RlOgo+PiBPbiBGcmksIDIwMTUtMDctMTAgYXQgMTY6
MTkgKzAyMDAsIFRob21hcyBHcmFmIHdyb3RlOgo+Pj4gRnJvbTogUm9vcGEgUHJhYmh1IDxyb29w
YUBjdW11bHVzbmV0d29ya3MuY29tPgo+Pgo+Pj4gKwlpZiAob2lmKQo+Pj4gKwkJZGV2ID0gX19k
ZXZfZ2V0X2J5X2luZGV4KG5ldCwgb2lmKTsKPj4+ICsJcmV0ID0gbHd0dW5uZWxfYnVpbGRfc3Rh
dGUoZGV2LCBlbmNhcF90eXBlLAo+Pj4gKwkJCQkgICBlbmNhcCwgJmx3dHN0YXRlKTsKPj4+ICsJ
aWYgKCFyZXQpIHsKPj4+ICsJCWx3dHVubmVsX3N0YXRlX2dldChsd3RzdGF0ZSk7Cj4+PiArCQly
ZXQgPSBsd3R1bm5lbF9jbXBfZW5jYXAobHd0c3RhdGUsIG5oLT5uaF9sd3RzdGF0ZSk7Cj4+PiAr
CQlsd3R1bm5lbF9zdGF0ZV9wdXQobHd0c3RhdGUpOwo+Pj4gKwo+Pj4gKwkJcmV0dXJuIHJldDsK
Pj4KPj4gVGhlc2UgX2dldCgpL19wdXQoKSBjYWxscyBkbyBub3Qgc2VlbSBuZWNlc3NhcnksIG9y
IGJ1Z2d5Lgo+Pgo+PiBJZiByZWZjb3VudGluZyBpcyBuZWVkZWQgdGhlIF9nZXQoKSBzaG91bGQg
YmUgZG9uZSBhdCB0aGUgdGltZSBsd3N0YXRlCj4+IGlzIGZldGNoZWQuCj4gSSdsbCBsZXQgUm9v
cGEgY29tbWVudCBidXQgaXQgc2VlbXMgbGlrZSB0aGVzZSBjYW4ganVzdCBiZSByZW1vdmVkLgpB
Z3JlZSwgVGhleSBkbyBzZWVtIHVubmVjZXNzYXJ5IGhlcmUuICBJIHdpbGwgZ2V0IHJpZCBvZiB0
aGVtLiB0aGFua3MuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0
Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
