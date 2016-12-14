From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost: introduce O(1) vq metadata cache
Date: Wed, 14 Dec 2016 17:33:40 +0800
Message-ID: <cb9d4dbe-0688-4ec9-dacd-bf569713a295@redhat.com>
References: <201612141605.QJowNf4i%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	virtualization@lists.linux-foundation.org,
	maxime.coquelin@redhat.com, kbuild-all@01.org,
	vkaplans@redhat.com, wexu@redhat.com
To: kbuild test robot <lkp@intel.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <201612141605.QJowNf4i%fengguang.wu@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE25bm0MTLmnIgxNOaXpSAxNjoxNCwga2J1aWxkIHRlc3Qgcm9ib3Qgd3JvdGU6Cj4g
SGkgSmFzb24sCj4KPiBbYXV0byBidWlsZCB0ZXN0IFdBUk5JTkcgb24gdmhvc3QvbGludXgtbmV4
dF0KPiBbYWxzbyBidWlsZCB0ZXN0IFdBUk5JTkcgb24gdjQuOSBuZXh0LTIwMTYxMjE0XQo+IFtp
ZiB5b3VyIHBhdGNoIGlzIGFwcGxpZWQgdG8gdGhlIHdyb25nIGdpdCB0cmVlLCBwbGVhc2UgZHJv
cCB1cyBhIG5vdGUgdG8gaGVscCBpbXByb3ZlIHRoZSBzeXN0ZW1dCj4KPiB1cmw6ICAgIGh0dHBz
Oi8vZ2l0aHViLmNvbS8wZGF5LWNpL2xpbnV4L2NvbW1pdHMvSmFzb24tV2FuZy92aG9zdC1pbnRy
b2R1Y2UtTy0xLXZxLW1ldGFkYXRhLWNhY2hlLzIwMTYxMjE0LTE2MDE1Mwo+IGJhc2U6ICAgaHR0
cHM6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvbXN0L3Zob3N0Lmdp
dCBsaW51eC1uZXh0Cj4gY29uZmlnOiBpMzg2LXJhbmRjb25maWcteDAwNS0yMDE2NTAgKGF0dGFj
aGVkIGFzIC5jb25maWcpCj4gY29tcGlsZXI6IGdjYy02IChEZWJpYW4gNi4yLjAtMykgNi4yLjAg
MjAxNjA5MDEKPiByZXByb2R1Y2U6Cj4gICAgICAgICAgIyBzYXZlIHRoZSBhdHRhY2hlZCAuY29u
ZmlnIHRvIGxpbnV4IGJ1aWxkIHRyZWUKClRoYW5rcywgVjIgd2lsbCBiZSBwb3N0ZWQgc29vbi4K
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxp
emF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9u
Lm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92
aXJ0dWFsaXphdGlvbg==
