From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3
 flow/port support
Date: Fri, 20 May 2016 19:14:20 +0900
Message-ID: <20160520101417.GA24509@penelope.isobedori.kobe.vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160517163250.7ead555e@griffin>
 <20160520052858.GA15505@vergenet.net>
 <20160520100028.0065a2ef@griffin>
 <20160520081120.GA17561@vergenet.net>
 <20160520081611.GB17561@vergenet.net>
 <20160520103939.723f2a42@griffin>
 <20160520091202.GC17561@vergenet.net>
 <20160520112004.4f0a54e7@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160520112004.4f0a54e7@griffin>
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

T24gRnJpLCBNYXkgMjAsIDIwMTYgYXQgMTE6MjA6MDRBTSArMDIwMCwgSmlyaSBCZW5jIHdyb3Rl
Ogo+IE9uIEZyaSwgMjAgTWF5IDIwMTYgMTg6MTI6MDUgKzA5MDAsIFNpbW9uIEhvcm1hbiB3cm90
ZToKClsuLi5dCgo+ID4gMy4gV2l0aCByZWdhcmRzIHRvIHRoZSBtaXJyb3JpbmcgcGFydCBvZiB5
b3VyIHF1ZXN0aW9uLCBJIG5lZWQgdG8gY2hlY2sKPiA+ICAgIG9uIHRoYXQgYW5kIHBvc3NpYmx5
IGl0cyBicm9rZW4uIEJ1dCBteSB0aGlua2luZyBpcyB0aGF0IGEgbWlycm9yaW5nCj4gPiAgICB2
cG9ydCB3b3VsZCByZWdhcmRlZCBpbiB0aGUgc2FtZSB3YXkgYXMgYW55IG90aGVyIHZwb3J0IGlu
IHRoaXMgcmVzcGVjdAo+ID4gICAgYW5kIHRoZSBwcmVzZW5jZSBvZiB0aGUgImxheWVyMyIgZmxh
ZyB3b3VsZCBjb250cm9sIHdoZXRoZXIgYW4gRXRoZXJuZXQKPiA+ICAgIGhlYWRlciBpcyBwcmVz
ZW50IG9yIG5vdC4KPiA+IAo+ID4gICAgSXQgbWF5IGJlIHRoZSBjYXNlIHRoYXQgaXRzIG5vdCBw
b3NzaWJsZSB0byB1c2UgYSB0dW5uZWwgdnBvcnQgYXMgYQo+ID4gICAgbWlycm9yaW5nIHZwb3J0
LiBBbmQgYXMgYWxsIG90aGVyIHZwb3J0cyBjdXJyZW50bHkgZG8gbm90IHN1cHBvcnQKPiA+ICAg
ICJsYXllcjMiIHRoZW4gY3VycmVudGx5IGFuIEV0aGVybmV0IGhlYWRlciB3b3VsZCBhbHdheXMg
YmUgcHJlc2VudAo+ID4gICAgb24gb3V0cHV0IHRvIGEgbWlycm9yLgo+IAo+IFdlIGNhbiBqdXN0
IHJlcXVpcmUgYSBtaXJyb3IgcG9ydCB0byBiZSBhbHdheXMgTDIgYW5kIG91dHB1dCB0aGUgTDMK
PiBwYWNrZXRzIHdpdGggemVybyBFdGhlcm5ldCBhZGRyZXNzZXMuIEZvciBtaXJyb3JpbmcsIHRo
aXMgc2hvdWxkIGJlCj4gb2theSg/KQoKWWVzLCBJIGV4cGVjdCB0aGF0IGlzIGEgZ29vZCBhcHBy
b2FjaC4KCkknbGwgbG9vayBvdmVyIHRoZSBjb2RlIHRvIHNlZSBhYm91dCBtYWtpbmcgdGhhdCBz
byBpZiBpdHMgbm90IGFscmVhZHkgdGhlCmNhc2UuCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
