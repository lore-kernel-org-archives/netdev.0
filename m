From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 21:07:10 -0700
Message-ID: <lexmby2wgxuu9h0vljo2a16m.1283054830069@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: eric.dumazet@gmail.com, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45342 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703Ab0H2EHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Aug 2010 00:07:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSBhbSBub3QgcmVhbGx5IHdvcnJpZWQuIGFib3V0IHNreTIgZHVhbCBwb3J0IHNpbmNlIHRoZSBk
dWFsIHBvcnQgYm9hcmRzIGFyZSByYXJlLiBJIG1pZ2h0IGhhdmUgb25lIG9mIHRoZSBmZXcgaW4g
dXNlIAoKRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiB3cm90ZToKCj5Gcm9tOiBT
dGVwaGVuIEhlbW1pbmdlciA8c2hlbW1pbmdlckB2eWF0dGEuY29tPgo+RGF0ZTogU2F0LCAyOCBB
dWcgMjAxMCAxNTozMToyNCAtMDcwMAo+Cj4+IE9uIFNhdCwgMjggQXVnIDIwMTAgMTQ6NDE6MzAg
LTA3MDAgKFBEVCkKPj4gRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiB3cm90ZToK
Pj4gCj4+PiBTaW5jZSBuZXRwb2xsIGRvZXMgc2ltaWxhciB0aGluZ3MsIHRoaXMgbWVhbnMgYm90
aCBOQVBJIGFuZCBuZXRwb2xsCj4+PiBjYW5ub3QgZnVuY3Rpb24gcHJvcGVybHkgd2l0aCBTS1ky
J3Mgc2Vjb25kIHBvcnQuICBJdCB3aWxsIG9ubHkgd29yawo+Pj4gcmlnaHQgb24gdGhlIGZpcnN0
IHBvcnQuCj4+IAo+PiBJIGtuZXcgbmV0cG9sbCB3YXMgYnJva2VuIG9uIHNlY29uZCBwb3J0Lgo+
Cj5XZWxsLCBub3cgd2Uga25vdyB0aGF0IEdSTyBpcyB0b28gOi0pCj4KPklmIHdlIHdpc2ggdG8g
a2VlcCB0aGUgb25lLXRvLW9uZSBtYXBwaW5nIG9mIE5BUEkgY29udGV4dHMgdG8KPmludGVycnVw
dCBzb3VyY2VzLCB3aGF0IHdlIGNhbiBkbyBpcyBwcm92aWRlIHNvbWUga2luZCBvZiAiZGV2IGxp
c3QiLgo+Cj5UaGUgb3RoZXIgb3B0aW9uIGlzIHRvIHJlZ2lzdGVyIHR3byBOQVBJIGNvbnRleHRz
IGFuZCBzY2hlZHVsZSB0aGVtCj5ib3RoIG9uIGFuIGludGVycnVwdC4KPgo+QnV0IGluIGJvdGgg
Y2FzZXMsIGRldGVjdGluZyB0aGUgZW5kIG9mIHBvbGxpbmcsIGFuZCB0aHVzIHdoZW4gdG8gdHVy
bgo+dGhlIGludGVycnVwdHMgYmFjayBvbiwgaXMgbm9uLXRyaXZpYWwuCj4KPkkgcmVhbGx5IGRv
bid0IGxpa2UgZWl0aGVyIHNvbHV0aW9uLCB0aGVyZWZvcmUsIHNvIEknbGwgdHJ5IHRvIGJyYWlu
Cj5zdG9ybSBvbiB0aGlzIGEgYml0IG1vcmUuCg==

