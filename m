From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: Re: Re:Re: Re: [PATCH net] ppp: Fix a
 scheduling-while-atomic bug in del_chan
Date: Thu, 10 Aug 2017 09:25:24 +0800 (CST)
Message-ID: <858bbc5.bb7a.15dc9bf024c.Coremail.gfree.wind@vip.163.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
 <697dbbd.7911.15dbf5ca3a6.Coremail.gfree.wind@vip.163.com>
 <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpW8W24=2atSyStwKPYJ9zmOO5XiznktT3V_3qn00R7r=Q@mail.gmail.com>
 <73e6ac77.45ea.15dc569d56a.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpU3hx-Y7OXTDWARFc08BE6qQ_cEjZb7ciVKrWPFh2j0JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: xeb@mail.ru, "David Miller" <davem@davemloft.net>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: "Cong Wang" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m173-177.vip.163.com ([123.58.177.173]:30774 "EHLO
        m173-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdHJBZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 21:25:35 -0400
In-Reply-To: <CAM_iQpU3hx-Y7OXTDWARFc08BE6qQ_cEjZb7ciVKrWPFh2j0JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXQgMjAxNy0wOC0xMCAwMjoxODo0NCwgIkNvbmcgV2FuZyIgPHhpeW91Lndhbmdjb25nQGdtYWls
LmNvbT4gd3JvdGU6Cj5PbiBUdWUsIEF1ZyA4LCAyMDE3IGF0IDEwOjEzIFBNLCBHYW8gRmVuZyA8
Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4gd3JvdGU6Cj4+IE1heWJlIEkgZGlkbid0IHNob3cgbXkg
ZXhwbGFuYXRpb24gY2xlYXJseS4KPj4gSSB0aGluayBpdCB3b24ndCBoYXBwZW4gYXMgSSBtZW50
aW9uZWQgaW4gdGhlIGxhc3QgZW1haWwuCj4+IEJlY2F1c2UgdGhlIHBwdHBfcmVsZWFzZSBpbnZv
a2VzIHRoZSBzeW5jaHJvbml6ZV9yY3UgdG8gbWFrZSBzdXJlIGl0LCBhbmQgYWN0dWFsbHkgdGhl
cmUgaXMgbm8gb25lIHdoaWNoIHdvdWxkIGludm9rZSBkZWxfY2hhbiBleGNlcHQgcHB0cF9yZWxl
YXNlLgo+PiBJdCBpcyBndWFyYW50ZWVkIGJ5IHRoYXQgdGhlIHBwdHBfcmVsZWFzZSBkb2Vzbid0
IHB1dCB0aGUgc29jayByZWZjbnQgdW50aWwgY29tcGxldGUgYWxsIGNsZWFudXAgaW5jbHVkZSBt
YXJraW5nIHNrX3N0YXRlIGFzIFBQUE9YX0RFQUQuCj4+Cj4+IEluIG90aGVyIHdvcmRzLCBldmVu
IHRob3VnaCB0aGUgcHB0cF9yZWxlYXNlIGlzIG5vdCB0aGUgbGFzdCB1c2VyIG9mIHRoaXMgc29j
aywgdGhlIG90aGVyIG9uZSB3b3VsZG4ndCBpbnZva2UgZGVsX2NoYW4gaW4gcHB0cF9zb2NrX2Rl
c3RydWN0Lgo+PiBCZWNhdXNlIHRoZSBjb25kaXRpb24gIiEoc2stPnNrX3N0YXRlICYgUFBQT1hf
REVBRCkiIG11c3QgYmUgZmFsc2UuCj4KPk9ubHkgaWYgc29jay0+c2sgaXMgYWx3YXlzIG5vbi1O
VUxMIGZvciBwcHRwX3JlbGVhc2UoKSwgd2hpY2gKPmlzIHdoYXQgSSBhbSBub3Qgc3VyZS4gSWYg
eW91IGxvb2sgYXQgb3RoZXIgLT5yZWxlYXNlKCksIHNpbWlsYXIgY2hlY2tzCj5hcmUgdGhlcmUg
dG9vLCBzbyBub3QganVzdCBmb3IgcHB0cC4KClllcy4gSXQgc2VlbXMgb25seSBpZiB0aGUgcmVs
ZWFzZSgpIGlzIGludm9rZWQgdHdpY2UsIHRoZSBzb2NrLT5zayB3b3VsZCBiZSBOVUxMLgpCdXQg
SSBkb24ndCBmaW5kIHRoZXJlIGlzIGFueSBjYXNlIHdoaWNoIGNvdWxkIGNhdXNlIGl0LgoKPgo+
Pgo+PiBBcyBzdW1tYXJ5LCB0aGUgZGVsX2NoYW4gYW5kIHBwcG94X3VuYmluZF9zb2NrIGluIHBw
dHBfc29ja19kZXN0cnVjdCBhcmUgdW5uZWNlc3NhcnkuCj4+IEFuZCBpdCBldmVuIGJyaW5ncyBj
b25mdXNpbmcuCj4KPlNvcnJ5LCBJIGNhbid0IGRyYXcgYW55IGNvbmNsdXNpb24gZm9yIHRoaXMu
CgpUaGFuayB5b3UgYWxsIHRoZSBzYW1lLCBhbmQgSSBoYXZlIGxlYXJuIGEgbG90IGZyb20geW91
IDopCldpc2ggc29tZW9uZSB3aGljaCBpcyBmYW1pbGlhciB3aXRoIHRoZXNlIGNvZGVzIGNvdWxk
IGdpdmUgbW9yZSBkZXRhaWxzIGFuZCBleHBsYW5hdGlvbnMuCgpCZXN0IFJlZ2FyZHMKRmVuZyAK
