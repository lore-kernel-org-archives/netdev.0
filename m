From: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Thu, 19 Oct 2017 12:19:42 +0000
Message-ID: <1508415582.1186.49.camel@cohaesio.com>
References: <1507121766.30720.4.camel@cohaesio.com>
         <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
         <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
         <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
         <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
         <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
         <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
         <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl>
         <f6e2208a-4cdf-3303-5999-92186b437b62@itcare.pl>
         <1704eb26-c4c5-b196-ca7a-5265e92ae4e6@itcare.pl>
         <bd82f85a-f9b8-a09a-beab-67667b58f36a@itcare.pl>
         <7fd828d7-c586-2c32-3ba6-e0575bf9958c@itcare.pl>
         <99eba19f-327e-e01f-4f4a-87540b176e40@itcare.pl>
         <efcc51b4-f911-11ec-1c56-fcf31081f9d5@itcare.pl>
         <d79df7f2-5de4-cc37-baf0-5603f025155e@itcare.pl>
         <748b6d9d-4a3f-4eaa-ad24-27060c2e2642@itcare.pl>
         <16c9fa34-252f-e5a3-8b15-e5a8c4d8a46f@itcare.pl>
         <12670bc6-439c-7ef4-109a-fd20384b9ca2@itcare.pl>
         <bd59ccc3-2af4-6842-8d2f-169229a61470@itcare.pl>
         <888ec430-1d70-68e6-2ee8-bab53d21bb0f@itcare.pl>
         <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "pavlos.parissis@gmail.com" <pavlos.parissis@gmail.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bender.cohaesio.com ([212.97.128.130]:56829 "EHLO
        mail.cohaesio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752794AbdJSMTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:19:44 -0400
In-Reply-To: <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
Content-Language: en-US
Content-ID: <B8AC68F2ED176A48AD7036EC8A36389F@surftown.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgQWxleCwNCg0KT24gb25zLCAyMDE3LTEwLTE4IGF0IDE2OjM3IC0wNzAwLCBBbGV4YW5kZXIg
RHV5Y2sgd3JvdGU6DQo+IFdoZW4gd2UgbGFzdCB0YWxrZWQgSSBoYWQgYXNrZWQgaWYgeW91IGNv
dWxkIGRvIGEgZ2l0IGJpc2VjdCB0byBmaW5kDQo+IHRoZSBtZW1vcnkgbGVhayBhbmQgeW91IHNh
aWQgeW91IHdvdWxkIGxvb2sgaW50byBpdC4gVGhlIG1vc3QgdXNlZnVsDQo+IHdheSB0byBzb2x2
ZSB0aGlzIHdvdWxkIGJlIHRvIGRvIGEgZ2l0IGJpc2VjdCBiZXR3ZWVuIHlvdXIgY3VycmVudA0K
PiBrZXJuZWwgYW5kIHRoZSA0LjExIGtlcm5lbCB0byBmaW5kIHRoZSBwb2ludCBhdCB3aGljaCB0
aGlzIHN0YXJ0ZWQuDQo+IElmDQo+IHdlIGNhbiBkbyB0aGF0IHRoZW4gZml4aW5nIHRoaXMgYmVj
b21lcyBtdWNoIHNpbXBsZXIgYXMgd2UganVzdCBoYXZlDQo+IHRvIGZpeCB0aGUgcGF0Y2ggdGhh
dCBpbnRyb2R1Y2VkIHRoZSBpc3N1ZS4NCg0KV2UncmUgYWxzbyBzZWVpbmcgYSBzbWFsbGVyIG1l
bW9yeSBsZWFrIChhYm91dCAxIEdCIHBlciBkYXkpIHRoYW4gdGhlDQpvcmlnaW5hbCBvbmUgZXZl
biB3aXRoIHRoZSAiRml4IG1lbW9yeSBsZWFrIHJlbGF0ZWQgZmlsdGVyIHByb2dyYW1taW5nDQpz
dGF0dXMiIGZpeCBhcHBsaWVkLiBTbyBmYXIgSSd2ZSBkZXRlcm1pbmVkIHRoYXQgdGhlIGxlYWsg
aXMgcHJlc2VudCBvbg0KNC4xMy43IGFuZCB3YXMgaW50cm9kdWNlZCBiZXR3ZWVuIDQuMTEgYW5k
IDQuMTIsIHNvIEknbGwgZG8gYW5vdGhlcg0Kcm91bmQgb2YgYmlzZWN0aW9uIHRvIGlkZW50aWZ5
IHRoZSBwYXRjaCB0aGF0IGludHJvZHVjZWQgdGhpcy4NCg0KU2luY2UgdGhlIHJvdXRlciBtdXN0
IHJ1biBmb3IgYSBjb3VwbGUgb2YgaG91cnMgYmVmb3JlIEkgY2FuIGJlIHN1cmUNCndoZXRoZXIg
YSBrZXJuZWwgaXMgZ29vZCBvciBiYWQsIGFuZCBJIGNhbid0IHJlYm9vdCBpdCBkdXJpbmcgd29y
a2luZw0KaG91cnMsIGl0J2xsIHByb2JhYmx5IGJlIGFib3V0IGEgd2VlayBiZWZvcmUgSSBoYXZl
IGEgcmVzdWx0Lg0KDQotLSANClZlbmxpZyBoaWxzZW4gLyBCZXN0IFJlZ2FyZHMNCg0KQW5kZXJz
IEsuIFBlZGVyc2VuDQpTZW5pb3IgVGVjaG5pY2FsIE1hbmFnZXINCg0KQ29oYWVzaW8gQS9TICAg
ICAgICAgICAgICAgICAgICAgICAgICBlbWFpbDogIGFrcEBjb2hhZXNpby5jb20NClBhcmtlbiB8
IFBlciBIZW5yaWsgTGluZ3MgQWxsw6kgNCwgNCAgIG1haW46ICAgKzQ1IDQ1IDg4IDA4IDg4DQpE
Sy0yMTAwIENvcGVuaGFnZW4gfCBEZW5tYXJrICAgICAgICAgIGRpcmVjdDogKzQ1IDQ1IDIwIDc4
IDExDQoNClZpc2l0IHVzIGF0IHd3dy5jb2hhZXNpby5jb20NCg0KQ29oYWVzaW8gaXMgYSBsZWFk
aW5nIElUIHNvbHV0aW9ucyBwcm92aWRlciBpbiBTY2FuZGluYXZpYSwgcHJvdmlkaW5nDQpjZXJ0
aWZpZWQgSVQgb3V0c291cmNpbmcsIHNlcnZpY2UgZGVzayBhbmQgbWFuYWdlZCBob3N0aW5nIHNv
bHV0aW9ucyB0bw0KcHJvZmVzc2lvbmFsIGN1c3RvbWVycy4=
