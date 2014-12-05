From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: set correct protocol on
	route lookup
Date: Fri, 5 Dec 2014 09:43:33 -0800
Message-ID: <CALnjE+p9dKTmf=BpjZbM7Yzn58GfgcOQrjKBTsrtjh8LXv8M1A@mail.gmail.com>
References: <0ead411e38bc57a8971ffd9826f7bf9bfdc6ccf1.1417796557.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0ead411e38bc57a8971ffd9826f7bf9bfdc6ccf1.1417796557.git.jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

T24gRnJpLCBEZWMgNSwgMjAxNCBhdCA4OjI0IEFNLCBKaXJpIEJlbmMgPGpiZW5jQHJlZGhhdC5j
b20+IHdyb3RlOgo+IFJlc3BlY3Qgd2hhdCB0aGUgY2FsbGVyIHBhc3NlZCB0byBvdnNfdHVubmVs
X2dldF9lZ3Jlc3NfaW5mby4KPgo+IEZpeGVzOiA4ZjBhYWQ2ZjM1ZjdlICgib3BlbnZzd2l0Y2g6
IEV4dGVuZCBwYWNrZXQgYXR0cmlidXRlIGZvciBlZ3Jlc3MgdHVubmVsIGluZm8iKQo+IFNpZ25l
ZC1vZmYtYnk6IEppcmkgQmVuYyA8amJlbmNAcmVkaGF0LmNvbT4KClRoYW5rcyBmb3IgdGhlIGZp
eC4KQWNrZWQtYnk6IFByYXZpbiBCIFNoZWxhciA8cHNoZWxhckBuaWNpcmEuY29tPgoKPiAtLS0K
PiAgbmV0L29wZW52c3dpdGNoL3Zwb3J0LmMgfCAyICstCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGlu
c2VydGlvbigrKSwgMSBkZWxldGlvbigtKQo+Cj4gZGlmZiAtLWdpdCBhL25ldC9vcGVudnN3aXRj
aC92cG9ydC5jIGIvbmV0L29wZW52c3dpdGNoL3Zwb3J0LmMKPiBpbmRleCBlNzcxYTQ2OTMzZTUu
Ljk1ODQ1MjZjMDc3OCAxMDA2NDQKPiAtLS0gYS9uZXQvb3BlbnZzd2l0Y2gvdnBvcnQuYwo+ICsr
KyBiL25ldC9vcGVudnN3aXRjaC92cG9ydC5jCj4gQEAgLTYwMCw3ICs2MDAsNyBAQCBpbnQgb3Zz
X3R1bm5lbF9nZXRfZWdyZXNzX2luZm8oc3RydWN0IG92c190dW5uZWxfaW5mbyAqZWdyZXNzX3R1
bl9pbmZvLAo+ICAgICAgICAgZmwuc2FkZHIgPSB0dW5fa2V5LT5pcHY0X3NyYzsKPiAgICAgICAg
IGZsLmZsb3dpNF90b3MgPSBSVF9UT1ModHVuX2tleS0+aXB2NF90b3MpOwo+ICAgICAgICAgZmwu
Zmxvd2k0X21hcmsgPSBza2JfbWFyazsKPiAtICAgICAgIGZsLmZsb3dpNF9wcm90byA9IElQUFJP
VE9fR1JFOwo+ICsgICAgICAgZmwuZmxvd2k0X3Byb3RvID0gaXBwcm90bzsKPgo+ICAgICAgICAg
cnQgPSBpcF9yb3V0ZV9vdXRwdXRfa2V5KG5ldCwgJmZsKTsKPiAgICAgICAgIGlmIChJU19FUlIo
cnQpKQo+IC0tCj4gMS44LjMuMQo+Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8v
b3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
