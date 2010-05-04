From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Tue, 4 May 2010 10:05:22 +0800
Message-ID: <w2l412e6f7f1005031905jf204b10ax67da6e9018ea81c4@mail.gmail.com>
References: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
	<1272897886.2226.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47034 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab0EDCF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 22:05:57 -0400
Received: by pva4 with SMTP id 4so699989pva.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 19:05:56 -0700 (PDT)
In-Reply-To: <1272897886.2226.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gTW9uLCBNYXkgMywgMjAxMCBhdCAxMDo0NCBQTSwgRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6
ZXRAZ21haWwuY29tPiB3cm90ZToKPgo+IEhtbSwgSSBmZWVsIHZlcnkgdW5jb21wZm9ydGFibGUg
d2l0aCB0aGlzIHBhdGNoLgo+Cj4gSSBhbSBwcmV0dHkgc3VyZSBzb21lIGNhbGxlcnMgZG9udCBj
aGVjayBtaW5pbXVtIGV0aGVybmV0IGZyYW1lIGxlbmd0aC4KPgo+IEF0IGxlYXN0IGEgV0FSTl9P
Tl9PTkNFKCkgaXMgbmVlZGVkLCBqdXN0IGluIGNhc2UuLi4KPiBJbiBmYWN0IG91ciBzdGFjayBo
YXMgZGlmZmVyZW50IHJlcXVpcmVtZW50cy4KPgo+IENoZWNrIG5ldC9pcHY0L2lwX2dyZS5jIGZv
ciBleGFtcGxlLgo+Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBpZiAodHVubmVsLT5kZXYtPnR5
cGUgPT0gQVJQSFJEX0VUSEVSKSB7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqBpZiAoIXBza2JfbWF5X3B1bGwoc2tiLCBFVEhfSExFTikpIHsKPiDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHN0YXRzLT5yeF9sZW5ndGhfZXJyb3JzKys7
Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBzdGF0cy0+
cnhfZXJyb3JzKys7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqBnb3RvIGRyb3A7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB9Cj4K
PiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoGlwaCA9IGlwX2hkcihza2IpOwo+
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgc2tiLT5wcm90b2NvbCA9IGV0aF90
eXBlX3RyYW5zKHNrYiwgdHVubmVsLT5kZXYpOwo+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgc2tiX3Bvc3RwdWxsX3Jjc3VtKHNrYiwgZXRoX2hkcihza2IpLCBFVEhfSExFTik7
Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB9Cj4KClNvIHRoZSBtaW5pbWFsIHBhY2tldCBsZW5n
dGggZXRoX3R5cGVfdHJhbnMoKSByZXF1aXJlcyBzaG91bGQgYmUKRVRIX0hMRU4sIG5vdCBFVEhf
WkxFTi4KCi0tIApSZWdhcmRz77yMCkNoYW5nbGkgR2FvKHhpYW9zdW9AZ21haWwuY29tKQo=
