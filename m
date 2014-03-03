From: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Subject: Re: change kmalloc into vmalloc for large memory
	allocations
Date: Sun, 2 Mar 2014 19:08:21 -0800
Message-ID: <20140303030821.GA16732@kroah.com>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
 <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
 <20140228163304.GA15614@kroah.com>
 <35FD53F367049845BC99AC72306C23D102844605F38F@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead.org'"
 <linux-arm-kernel@lists.infradead.org>,
 "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
 "'linux-kern
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D102844605F38F@CNBJMBX05.corpusers.net>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

T24gTW9uLCBNYXIgMDMsIDIwMTQgYXQgMTA6NTE6MjNBTSArMDgwMCwgV2FuZywgWWFsaW4gd3Jv
dGU6Cj4gSGkgIGdyZWcsCj4gCj4gSSBhbSBzb3JyeSwKPiBJIG1ha2UgYSBtaXN0YWtlICwKPiBZ
b3UgYXJlIHJpZ2h0ICwKPiBodHRwczovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgva2VybmVs
L2dpdC93aWxsL2xpbnV4LmdpdC90cmVlL2RyaXZlcnMvdXNiL2dhZGdldC9mX21hc3Nfc3RvcmFn
ZS5jP2g9bWFzdGVyI24yNzI0Cj4gCj4gdGhpcyBvbmUgc2hvdWxkIG5vdCBjaGFuZ2VkIHRvIHVz
ZSB2bWFsbG9jLAo+IHRoZSBidWZmZXIgd2lsbCBiZSB1c2VkIGJ5IERNQe+8jAoKV2hpY2ggaXMg
d2h5IGEgd3JhcHBlciBmdW5jdGlvbiB3aWxsIG5ldmVyIHdvcmsuCgo+IG90aGVycyBzaG91bGQg
YmUgc2FmZSB0byBjaGFuZ2U6Cj4gCj4gaHR0cHM6Ly9naXQua2VybmVsLm9yZy9jZ2l0L2xpbnV4
L2tlcm5lbC9naXQvd2lsbC9saW51eC5naXQvdHJlZS9zb3VuZC9zb2Mvc29jLWNvcmUuYz9oPW1h
c3RlciNuMzc3Mgo+IAo+IGh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcvY2dpdC9saW51eC9rZXJuZWwv
Z2l0L3dpbGwvbGludXguZ2l0L3RyZWUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfZnRwLmM/
aD1tYXN0ZXIjbjYwMwo+IGh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcvY2dpdC9saW51eC9rZXJuZWwv
Z2l0L3dpbGwvbGludXguZ2l0L3RyZWUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfaDMyM19t
YWluLmM/aD1tYXN0ZXIjbjE4NDkKPiBodHRwczovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgv
a2VybmVsL2dpdC93aWxsL2xpbnV4LmdpdC90cmVlL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNr
X2lyYy5jP2g9bWFzdGVyI24yNDcKPiBodHRwczovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgv
a2VybmVsL2dpdC93aWxsL2xpbnV4LmdpdC90cmVlL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNr
X3NhbmUuYz9oPW1hc3RlciNuMTk1Cj4gCj4gaHR0cHM6Ly9naXQua2VybmVsLm9yZy9jZ2l0L2xp
bnV4L2tlcm5lbC9naXQvd2lsbC9saW51eC5naXQvdHJlZS9kcml2ZXJzL2lucHV0L2V2ZGV2LmM/
aD1tYXN0ZXIjbjQwMwoKVGhlbiBzZW5kIGluZGl2aWR1YWwgcGF0Y2hlcyBmb3IgdGhlc2UgYW5k
IHNlZSB3aGF0IGhhcHBlbnMuCgpncmVnIGstaApfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpBbHNhLWRldmVsIG1haWxpbmcgbGlzdApBbHNhLWRldmVsQGFs
c2EtcHJvamVjdC5vcmcKaHR0cDovL21haWxtYW4uYWxzYS1wcm9qZWN0Lm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2Fsc2EtZGV2ZWwK
