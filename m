From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [PATCH net-next] net: sched: Add the invalid handle check in
 qdisc_class_find
Date: Tue, 22 Aug 2017 08:46:29 +0800 (CST)
Message-ID: <caf756f.76ba.15e0767aea0.Coremail.gfree.wind@vip.163.com>
References: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
 <20170821.104749.419102990180912192.davem@davemloft.net>
 <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>,
        "Jamal Hadi Salim" <jhs@mojatatu.com>
To: "Cong Wang" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m171-177.vip.163.com ([123.58.177.171]:11350 "EHLO
        m171-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754049AbdHVArm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:47:42 -0400
In-Reply-To: <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXQgMjAxNy0wOC0yMiAwMzo1ODowMywgIkNvbmcgV2FuZyIgPHhpeW91Lndhbmdjb25nQGdtYWls
LmNvbT4gd3JvdGU6Cj5PbiBNb24sIEF1ZyAyMSwgMjAxNyBhdCAxMDo0NyBBTSwgRGF2aWQgTWls
bGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiB3cm90ZToKPj4gRnJvbTogZ2ZyZWUud2luZEB2aXAu
MTYzLmNvbQo+PiBEYXRlOiBGcmksIDE4IEF1ZyAyMDE3IDE1OjIzOjI0ICswODAwCj4+Cj4+PiBG
cm9tOiBHYW8gRmVuZyA8Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4KPj4+Cj4+PiBBZGQgdGhlIGlu
dmFsaWQgaGFuZGxlICIwIiBjaGVjayB0byBhdm9pZCB1bm5lY2Vzc2FyeSBzZWFyY2gsIGJlY2F1
c2UKPj4+IHRoZSBxZGlzYyB1c2VzIHRoZSBza2ItPnByaW9yaXR5IGFzIHRoZSBoYW5kbGUgdmFs
dWUgdG8gbG9vayB1cCwgYW5kCj4+PiBpdCBpcyAiMCIgdXN1YWxseS4KPj4+Cj4+PiBTaWduZWQt
b2ZmLWJ5OiBHYW8gRmVuZyA8Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4KPj4KPj4gSmFtYWwsIENv
bmcsIHBsZWFzZSByZXZpZXcuCj4+Cj4+IElmICdpZCcgemVybyBpcyBuZXZlciBoYXNoZWQgaW50
byB0aGUgdGFibGVzLCB0aGlzIGNoYW5nZSBsb29rcwo+PiBsZWdpdGltYXRlLgo+Cj5Mb29rcyBn
b29kIHRvIG1lLgo+Cj5HYW8sIGluIHRoZSBmdXR1cmUgcGxlYXNlIENjIG1haW50YWluZXJzIGRp
cmVjdGx5LCB5b3UgY2FuCj51c2UgLi9zY3JpcHRzL2dldF9tYWludGFpbmVyLnBsLgo+Cj5UaGFu
a3MuCgpIaSBDb25nLAoKVGhhbmtzIHlvdXIgcmVtaW5kZXIgZmlyc3RseS4KQnV0IEkgaGFkIHVz
ZWQgdGhlIGdldF9tYWludGFpbmVyLnBsIGFjdHVhbGx5IGJlZm9yZSBzZW50IHRoZSBwYXRjaC4K
ClRoZSBmb2xsb3dpbmcgaXMgdGhlIG91dHB1dC4KW2ZnYW9AaWt1YWk4IG5ldC1uZXh0XSMuL3Nj
cmlwdHMvZ2V0X21haW50YWluZXIucGwgcGF0Y2hfU2NoZUNoZWNrLzAwMDEtbmV0LXNjaGVkLUFk
ZC10aGUtaW52YWxpZC1oYW5kbGUtY2hlY2staW4tcWRpc2NfY2xhcy5wYXRjaAoiRGF2aWQgUy4g
TWlsbGVyIiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4gKG1haW50YWluZXI6TkVUV09SS0lORyBbR0VO
RVJBTF0pCm5ldGRldkB2Z2VyLmtlcm5lbC5vcmcgKG9wZW4gbGlzdDpORVRXT1JLSU5HIFtHRU5F
UkFMXSkKbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZyAob3BlbiBsaXN0KQoKSSBkb24ndCBr
bm93IGlmIGl0IGlzIGFuIGlzc3VlIG9mIHRoZSBzY3JpcHQgImdldF9tYWludGFpbmVyLnBsIiAg
b3IgbXkgdXNhZ2UgaXMgd3JvbmcuCgpBbnl3YXksIHRoYW5rcyB5b3UgJiBKYW1hbCdzIHJldmll
dy4KCkJlc3QgUmVnYXJkcwpGZW5nCgo=
