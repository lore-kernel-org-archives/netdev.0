From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: Re:Re: Re:Re: Re: [PATCH net] ppp: Fix a
 scheduling-while-atomic bug in del_chan
Date: Thu, 10 Aug 2017 10:41:49 +0800 (CST)
Message-ID: <44673dfb.d38a.15dca04f711.Coremail.gfree.wind@vip.163.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
 <697dbbd.7911.15dbf5ca3a6.Coremail.gfree.wind@vip.163.com>
 <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpW8W24=2atSyStwKPYJ9zmOO5XiznktT3V_3qn00R7r=Q@mail.gmail.com>
 <73e6ac77.45ea.15dc569d56a.Coremail.gfree.wind@vip.163.com>
 <1abb4a1f.6499.15dc5dae314.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWTfV00qcda75f1Oh3LcFt9w8kPsp3HHF18vjO9mv+Dbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: xeb@mail.ru, "David Miller" <davem@davemloft.net>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: "Cong Wang" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m173-177.vip.163.com ([123.58.177.173]:20090 "EHLO
        m173-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdHJCmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 22:42:05 -0400
In-Reply-To: <CAM_iQpWTfV00qcda75f1Oh3LcFt9w8kPsp3HHF18vjO9mv+Dbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CkF0IDIwMTctMDgtMTAgMDU6MDA6MTksICJDb25nIFdhbmciIDx4aXlvdS53YW5nY29uZ0BnbWFp
bC5jb20+IHdyb3RlOgo+T24gV2VkLCBBdWcgOSwgMjAxNyBhdCAxMjoxNyBBTSwgR2FvIEZlbmcg
PGdmcmVlLndpbmRAdmlwLjE2My5jb20+IHdyb3RlOgo+PiBIaSBDb25nLAo+Pgo+PiBBY3R1YWxs
eSBJIGhhdmUgb25lIHF1ZXN0aW9uIGFib3V0IHRoZSBTT0NLX1JDVV9GUkVFLgo+PiBJIGRvbid0
IHRoaW5rIGl0IGNvdWxkIHJlc29sdmUgdGhlIGlzc3VlIHlvdSByYWlzZWQgZXZlbiB0aG91Z2gg
aXQgZXhpc3RzIHJlYWxseS4KPj4KPj4gSSBjaGVja2VkIHRoZSBTT0NLX1JDVV9GUkVFLCBpdCBq
dXN0IGRlZmVyIHRoZSBfX3NrX2Rlc3RydWN0IGFmdGVyIG9uZSByY3UgcGVyaW9kLgo+PiBCdXQg
d2hlbiBpdCBwZXJmb3Jtcywgc29tZW9uZSBzdGlsbCBjb3VsZCBmaW5kIHRoaXMgc29jayBieSBj
YWxsaWQgZHVyaW5nIHRoZSBkZWxfY2hhbiBwZXJpb2QgYW5kIGl0IG1heSBzdGlsbCBkZWZlcmVu
Y2UgdGhlIHNvY2sgd2hpY2ggbWF5IGZyZWVkIHNvb24uCj4+Cj4+IFRoZSByaWdodCBmbG93IHNo
b3VsZCBiZSBmb2xsb3dpbmcuCj4+IGRlbF9jaGFuKCkKPj4gd2FpdCBhIHJjdSBwZXJpb2QKPj4g
c29ja19wdXQoKSAtLS0tLS0tLS0tLS0gSXQgaXMgc2FmZSB0aGF0IHNvbWVvbmUgZ2V0cyB0aGUg
c29jayBiZWNhdXNlIGl0IGFscmVhZHkgaG9sZCBzb2NrIHJlZmNudC4KPj4KPj4gV2hlbiB1c2lu
ZyBTT0NLX1JDVV9GUkVFLCBpdHMgZmxvdyB3b3VsZCBiZSBmb2xsb3dpbmcuCj4+IHdhaXQgYSBy
Y3UgcGVyaW9kCj4+IGRlbF9jaGFuKCkKPj4gZnJlZSB0aGUgc29jayBkaXJlY3RseSAtLS0tLS0t
LSBubyBzb2NrIHJlZmNudCBjaGVjayBhZ2Fpbi4KPj4gQmVjYXVzZSB0aGUgZGVsX2NoYW4gaGFw
cGVucyBhZnRlciByY3Ugd2FpdCwgbm90IGJlZm9yZSwgc28gaXQgaXNuJ3QgaGVscGZ1bCB3aXRo
IFNPQ0tfUkNVX0ZSRUUuCj4KPgo+WWVzLCBnb29kIHBvaW50ISBXaXRoIFNPQ0tfUkNVX0ZSRUUg
dGhlIHNvY2tfaG9sZCgpIHNob3VsZAo+bm90IGJlIG5lZWRlZC4gRm9yIFJDVSwgdW5wdWJsaXNo
IHNob3VsZCBpbmRlZWQgaGFwcGVuIGJlZm9yZQo+Z3JhY2UgcGVyaW9kLgoKU29ycnksIEkgY291
bGRuJ3QgdW5kZXJzdGFuZCB3aHkgc29ja19ob2xkKCkgaXNuJ3QgbmVjZXNzYXJ5IHdpdGggU09D
S19SQ1VfRlJFRS4KV2hlbiBsb29rdXBfY2hhbiBmaW5kcyB0aGUgc29jaywgaXQgd291bGQgcmV0
dXJuIGFuZCByZWZlcmVuY2UgaXQgbGF0ZXIuCklmIG5vIHJlZmNudCwgaG93IHRvIHByb3RlY3Qg
dGhlIHNvY2sgPwoKQmVzdCBSZWdhcmRzCkZlbmcKCj4KPgo+Pgo+PiBJIGRvbid0IGtub3cgaWYg
SSBtaXN1bmRlcnN0YW5kIHRoZSBTT0NLX1JDVV9GUkVFIHVzYWdlLgo+Pgo+PiBCdXQgaXQgaXMg
YSBnb29kIG5ld3MgdGhhdCB0aGUgZGVsX2NoYW4gaXMgb25seSBpbnZva2VkIGluIHBwdHBfcmVs
ZWFzZSBhY3R1YWxseSBhbmQgaXQgd291bGQgd2FpdCBhIHJjdSBwZXJpb2QgYmVmb3JlIHNvY2tf
cHV0Lgo+Pgo+Cj5Mb29raW5nIGF0IHRoZSBjb2RlIGFnYWluLCB0aGUgcmVhZGVyIGxvb2t1cF9j
aGFuKCkgaXMgYWN0dWFsbHkKPmludm9rZWQgaW4gQkggY29udGV4dCwgYnV0IG5laXRoZXIgYWRk
X2NoYW4oKSBub3IgZGVsX2NoYW4oKQo+YWN0dWFsbHkgZGlzYWJsZXMgQkguLi4KCgo=
