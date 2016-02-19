From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Thu, 18 Feb 2016 18:11:46 -0800
Message-ID: <CALx6S37BwWg99poR4OeB1PyKEp0gtQSHwAsFMfXf=nZh6Ri8wg@mail.gmail.com>
References: <1455036424-6403-1-git-send-email-david@weave.works>
 <1455036424-6403-3-git-send-email-david@weave.works>
 <CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
 <86a8n86bcs.fsf@weave.works>
 <CAEh+42iGHk9zVYPcpSz5w5XPg450p8avuQLbMZZH+B5fZvF9WQ@mail.gmail.com>
 <CALx6S36kvXJUZM8_vEmF8L3bxnRiBh98Rs0wAd-HGBJ9Yyde_Q@mail.gmail.com>
 <CAEh+42gyHEALCjZZGjMWTLQsPgp191c4dfZYFffOL6iV7pwYHw@mail.gmail.com>
 <86vb5o3kd5.fsf@weave.works>
 <CALx6S37OgkxTLv6XEjFN4T=W8ZdZV_kx4wtPqtVwMizoUXbpVw@mail.gmail.com>
 <86bn7e2c3t.fsf@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Wragg <david-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <86bn7e2c3t.fsf-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
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

T24gVGh1LCBGZWIgMTgsIDIwMTYgYXQgODo1NCBBTSwgRGF2aWQgV3JhZ2cgPGRhdmlkQHdlYXZl
LndvcmtzPiB3cm90ZToKPiBUb20gSGVyYmVydCA8dG9tQGhlcmJlcnRsYW5kLmNvbT4gd3JpdGVz
Ogo+PiBQbGVhc2UgaW1wbGVtZW50IGxpa2UgaW4gaXBfdHVubmVsX2NoYW5nZV9tdHUgKG9yIGJl
dHRlciB5ZXQgY2FsbCBpdCksCj4+IHRoYXQgaXMgdGhlIHByZWNlZGVudCBmb3IgdHVubmVscy4K
Pgo+IEkndmUgbWFkZSBnZW5ldmVfY2hhbmdlX210dSBmb2xsb3cgaXBfdHVubmVsX2NoYW5nZV9t
dHUgaW4gdjIuCj4KPiBJZiBpdCB3ZXJlIHRvIGNhbGwgaXQgaW5zdGVhZCwgYXJlIHlvdSBzdWdn
ZXN0aW5nIGp1c3QgcGFzc2luZyBpbgo+IHRfaGxlbj8gIE9yIHJlc3RydWN0dXJpbmcgZ2VuZXZl
LmMgdG8gcmUtdXNlIHRoZSB3aG9sZSBpcF90dW5uZWwKPiBpbmZyYXN0cnVjdHVyZT8KPgpJJ2xs
IGxlYXZlIHRoYXQgdG8geW91IHRvIGRlY2lkZSBpZiB0aGF0IGlzIGZlYXNpYmxlIG9yIG1ha2Vz
IHNlbnNlLApidXQgaXBfdHVubmVsIGRvZXMgZG8gc29tZSBvdGhlciBpbnRlcmVzdGluZyB0aGlu
Z3MuIFN1cHBvcnQgZm9yCmdlbmV2ZSBjb3VsZCBlYXNpbHkgYmUgaW1wbGVtZW50ZWQgdXNpbmcg
aXBfdHVubmVsX2VuY2FwIGZhY2lsaXR5LiBUaGUKZGVmYXVsdCBNVFUgb24gdGhlIGRldmljZSBp
cyBzZXQgYmFzZWQgb24gdGhlIE1UVSBvZiB0aGUgb3V0Z29pbmcKaW50ZXJmYWNlIGFuZCB0dW5u
ZWwgb3ZlcmhlYWQtLSB0aGlzIHNob3VsZCBtaXRpZ2F0ZSB0aGUgcG9zc2liaWxpdHkKb2YgYSBs
b3Qgb2YgZnJhZ21lbnRhdGlvbiBoYXBwZW5pbmcgd2l0aGluIHRoZSB0dW5uZWwuIEFsc28sIHRo
ZQpvdXRwdXQgaW5mcmFzdHJ1Y3R1cmUgY2FjaGVzIHRoZSByb3V0ZSBmb3IgdGhlIHR1bm5lbCB3
aGljaCBpcyBhIG5pY2UKcGVyZm9ybWFuY2Ugd2luLgoKPiBBbHNvLCBJJ20gbm90IHN1cmUgd2hl
cmUgdGhlIDB4RkZGOCBjb21lcyBmcm9tIGluCj4gX19pcF90dW5uZWxfY2hhbmdlX210dS4gIEFu
eSBpZGVhcyB3aHkgMHhGRkY4IHJhdGhlciB0aGFuIDB4ZmZmZj8gIEl0Cj4gZ29lcyBhbGwgdGhl
IHdheSBiYWNrIHRvIHRoZSBpbml0YWwgaW1wb3J0IG9mIHRoZSBrZXJuZWwgaW50byBnaXQuCj4K
WWVzLCB0aGF0J3MgcHJldHR5IHVnbHkuIEZlZWwgZnJlZSB0byByZXBsYWNlIHRoYXQgd2l0aCBh
ICNkZWZpbmUgb3IKYXQgbGVhc3QgcHV0IGEgY29tbWVudCBhYm91dCBpdCBmb3IgdGhlIGJlbmVm
aXQgb2YgZnV0dXJlIGdlbmVyYXRpb25zLgoKVGhhbmtzLApUb20KCj4gRGF2aWQKX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApk
ZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5m
by9kZXYK
