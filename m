From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3
 flow/port support
Date: Tue, 10 May 2016 14:07:29 +0200
Message-ID: <20160510140729.65caf946@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160506113504.77a9504e@griffin>
 <20160509081818.GB4470@vergenet.net>
 <79BBBFE6CB6C9B488C1A45ACD284F51913CB6446@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Yang, Yi Y" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <79BBBFE6CB6C9B488C1A45ACD284F51913CB6446-0J0gbvR4kTggGBtAFL8yw7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
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

UGxlYXNlIGRvIG5vdCB0b3AgcG9zdC4KCk9uIFR1ZSwgMTAgTWF5IDIwMTYgMDA6MTY6MzYgKzAw
MDAsIFlhbmcsIFlpIFkgd3JvdGU6Cj4gSSB0aGluayBpdCBpcyBzdGlsbCBuZWNlc3NhcnkgdG8g
a2VlcCBldGhfdHlwZSBpbiBwdXNoX2V0aCBhY3Rpb24sIGZvcgo+IHRoZSBjbGFzc2lmaWVyIGNh
c2UsIGl0IHdpbGwgcHVzaF9uc2ggdGhlbiBwdXNoX2V0aCBmb3IgdGhlIG9yaWdpbmFsCj4gZnJh
bWUsIHRoaXMgd2lsbCBuZWVkIHRvIHNldCBldGhfdHlwZSB0byAweDg5NGYgYnkgcHVzaF9ldGgs
IG90aGVyd2lzZQo+IHB1c2hfZXRoIHdvbid0IGtub3cgdGhpcyBldGhfdHlwZS4KCk5vcGUsIHB1
c2hfbnNoIHdpbGwgc2V0IHNrYi0+cHJvdG9jb2wgdG8gRVRIX1BfTlNILiBMYXRlciBwdXNoX2V0
aCB3aWxsCnVzZSB0aGF0IHZhbHVlIGNvcnJlY3RseS4KCiBKaXJpCl9fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52
c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
