From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net v3] ovs: limit ovs recursions in
 ovs_execute_actions to not corrupt stack
Date: Fri, 15 Jan 2016 17:51:42 +0100
Message-ID: <5699239E.9020706@stressinduktion.org>
References: <1452868427-5655-1-git-send-email-hannes@stressinduktion.org>
 <1452876357.1223.178.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1452876357.1223.178.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
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

T24gMTUuMDEuMjAxNiAxNzo0NSwgRXJpYyBEdW1hemV0IHdyb3RlOgo+IE9uIEZyaSwgMjAxNi0w
MS0xNSBhdCAxNTozMyArMDEwMCwgSGFubmVzIEZyZWRlcmljIFNvd2Egd3JvdGU6Cj4+IEl0IHdh
cyBzZWVuIHRoYXQgZGVmZWN0aXZlIGNvbmZpZ3VyYXRpb25zIG9mIG9wZW52c3dpdGNoIGNvdWxk
IG92ZXJ3cml0ZQo+PiB0aGUgU1RBQ0tfRU5EX01BR0lDIGFuZCBjYXVzZSBhIGhhcmQgY3Jhc2gg
b2YgdGhlIGtlcm5lbCBiZWNhdXNlIG9mIHRvbwo+PiBtYW55IHJlY3Vyc2lvbnMgd2l0aGluIG92
cy4KPgo+IC4uLgo+Cj4+ICsKPj4gKwlwcmVlbXB0X2Rpc2FibGUoKTsKPj4gKwlsZXZlbCA9IF9f
dGhpc19jcHVfaW5jX3JldHVybihleGVjX2FjdGlvbnNfbGV2ZWwpOwo+PiArCWlmIChsZXZlbCA+
IG92c19yZWN1cnNpb25fbGltaXQpIHsKPgo+IGlmICh1bmxpa2VseShsZXZlbCA+IG92c19yZWN1
cnNpb25fbGltaXQpKSB7Cj4KClRoYW5rcywgSSBhZGRlZCBpdCEKCkJ5ZSwKSGFubmVzCgoKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcg
bGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9s
aXN0aW5mby9kZXYK
