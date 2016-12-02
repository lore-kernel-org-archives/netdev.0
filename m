From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net v3] tipc: check minimum bearer MTU
Date: Fri, 2 Dec 2016 20:07:15 +0800
Message-ID: <ba271624-f7aa-165e-950e-cf56b4c7621e@windriver.com>
References: <20161202083341.BB955A0F33@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Qian, netdev@vger.kernel.org, Zhang <zhangqian-c@360.cn>,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Kubecek <mkubecek@suse.cz>, Jon Maloy <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20161202083341.BB955A0F33@unicorn.suse.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gMTIvMDIvMjAxNiAwNDozMyBQTSwgTWljaGFsIEt1YmVjZWsgd3JvdGU6Cj4gUWlhbiBaaGFu
ZyAo5byg6LCmKSByZXBvcnRlZCBhIHBvdGVudGlhbCBzb2NrZXQgYnVmZmVyIG92ZXJmbG93IGlu
Cj4gdGlwY19tc2dfYnVpbGQoKSB3aGljaCBpcyBhbHNvIGtub3duIGFzIENWRS0yMDE2LTg2MzI6
IGR1ZSB0bwo+IGluc3VmZmljaWVudCBjaGVja3MsIGEgYnVmZmVyIG92ZXJmbG93IGNhbiBvY2N1
ciBpZiBNVFUgaXMgdG9vIHNob3J0IGZvcgo+IGV2ZW4gdGlwYyBoZWFkZXJzLiBBcyBhbnlvbmUg
Y2FuIHNldCBkZXZpY2UgTVRVIGluIGEgdXNlci9uZXQgbmFtZXNwYWNlLAo+IHRoaXMgaXNzdWUg
Y2FuIGJlIGFidXNlZCBieSBhIHJlZ3VsYXIgdXNlci4KPgo+IEFzIGFncmVlZCBpbiB0aGUgZGlz
Y3Vzc2lvbiBvbiBCZW4gSHV0Y2hpbmdzJyBvcmlnaW5hbCBwYXRjaCwgd2Ugc2hvdWxkCj4gY2hl
Y2sgdGhlIE1UVSBhdCB0aGUgbW9tZW50IGEgYmVhcmVyIGlzIGF0dGFjaGVkIHJhdGhlciB0aGFu
IGZvciBlYWNoCj4gcHJvY2Vzc2VkIHBhY2tldC4gV2UgYWxzbyBuZWVkIHRvIHJlcGVhdCB0aGUg
Y2hlY2sgd2hlbiBiZWFyZXIgTVRVIGlzCj4gYWRqdXN0ZWQgdG8gbmV3IGRldmljZSBNVFUuIFVE
UCBjYXNlIGFsc28gbmVlZHMgYSBjaGVjayB0byBhdm9pZAo+IG92ZXJmbG93IHdoZW4gY2FsY3Vs
YXRpbmcgYmVhcmVyIE1UVS4KPgo+IEZpeGVzOiBiOTdiZjNmZDhmNmEgKCJbVElQQ10gSW5pdGlh
bCBtZXJnZSIpCj4gU2lnbmVkLW9mZi1ieTogTWljaGFsIEt1YmVjZWsgPG1rdWJlY2VrQHN1c2Uu
Y3o+Cj4gUmVwb3J0ZWQtYnk6IFFpYW4gWmhhbmcgKOW8oOiwpikgPHpoYW5ncWlhbi1jQDM2MC5j
bj4KPiAtLS0KClRoYW5rcywgaXQgbG9va3MgbmljZSB0byBtZS4KCkFja2VkLWJ5OiBZaW5nIFh1
ZSA8eWluZy54dWVAd2luZHJpdmVyLmNvbT4KCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KQ2hlY2sg
b3V0IHRoZSB2aWJyYW50IHRlY2ggY29tbXVuaXR5IG9uIG9uZSBvZiB0aGUgd29ybGQncyBtb3N0
IAplbmdhZ2luZyB0ZWNoIHNpdGVzLCBTbGFzaERvdC5vcmchIGh0dHA6Ly9zZG0ubGluay9zbGFz
aGRvdApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwp0aXBj
LWRpc2N1c3Npb24gbWFpbGluZyBsaXN0CnRpcGMtZGlzY3Vzc2lvbkBsaXN0cy5zb3VyY2Vmb3Jn
ZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vdGlwYy1k
aXNjdXNzaW9uCg==
