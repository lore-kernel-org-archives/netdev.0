From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: Re: change kmalloc into vmalloc for large memory
	allocations
Date: Fri, 28 Feb 2014 17:20:08 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
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
 "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
 "'li
To: 'Huang Shijie' <b32955@freescale.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <53104ECA.4010702@freescale.com>
Content-Language: en-US
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

SGkgIA0KDQoNClllYWgsICANCkRtYSBidWZmZXIgbXVzdCBiZSBhbGxvY2F0ZWQgYnkga21hbGxv
YywNCg0KQnV0IHRoZSBtb2R1bGVzIEkgbGlzdCBzaG91bGQgY2FuIGFsbCBiZSBjaGFuZ2VkIHRv
IHVzZQ0Kdm1hbGxvYywgYmVjYXVzZSB0aGUgYnVmZmVyIGlzIG9ubHkgdXNlZCBieSBzb2Z0d2Fy
ZSwNCk5vdCBieSBhbnkgaGFyZHdhcmUgLg0KDQoNClRoYW5rcw0KDQotLS0tLU9yaWdpbmFsIE1l
c3NhZ2UtLS0tLQ0KRnJvbTogSHVhbmcgU2hpamllIFttYWlsdG86YjMyOTU1QGZyZWVzY2FsZS5j
b21dIA0KU2VudDogRnJpZGF5LCBGZWJydWFyeSAyOCwgMjAxNCA0OjU1IFBNDQpUbzogV2FuZywg
WWFsaW4NCkNjOiAnbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZyc7ICdsaW51eC1hcm0tbXNt
QHZnZXIua2VybmVsLm9yZyc7ICdsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcn
OyAnbGludXgtaW5wdXRAdmdlci5rZXJuZWwub3JnJzsgJ2JhbGJpQHRpLmNvbSc7ICdncmVna2hA
bGludXhmb3VuZGF0aW9uLm9yZyc7ICdscmdAdGkuY29tJzsgJ2Jyb29uaWVAb3BlbnNvdXJjZS53
b2xmc29ubWljcm8uY29tJzsgJ3BlcmV4QHBlcmV4LmN6JzsgJ3Rpd2FpQHN1c2UuZGUnOyAncGFi
bG9AbmV0ZmlsdGVyLm9yZyc7ICdrYWJlckB0cmFzaC5uZXQnOyAnZGF2ZW1AZGF2ZW1sb2Z0Lm5l
dCc7ICdyb3N0ZWR0QGdvb2RtaXMub3JnJzsgJ2Z3ZWlzYmVjQGdtYWlsLmNvbSc7ICdtaW5nb0By
ZWRoYXQuY29tJzsgJ2RtaXRyeS50b3Jva2hvdkBnbWFpbC5jb20nOyAncnlkYmVyZ0BldXJvbWFp
bC5zZSc7ICdsaW51eC11c2JAdmdlci5rZXJuZWwub3JnJzsgJ2Fsc2EtZGV2ZWxAYWxzYS1wcm9q
ZWN0Lm9yZyc7ICduZXRmaWx0ZXItZGV2ZWxAdmdlci5rZXJuZWwub3JnJzsgJ25ldGZpbHRlckB2
Z2VyLmtlcm5lbC5vcmcnOyAnY29yZXRlYW1AbmV0ZmlsdGVyLm9yZyc7ICduZXRkZXZAdmdlci5r
ZXJuZWwub3JnJw0KU3ViamVjdDogUmU6IGNoYW5nZSBrbWFsbG9jIGludG8gdm1hbGxvYyBmb3Ig
bGFyZ2UgbWVtb3J5IGFsbG9jYXRpb25zDQoNCuS6jiAyMDE05bm0MDLmnIgyOOaXpSAxNjoxNSwg
V2FuZywgWWFsaW4g5YaZ6YGTOg0KPiBjb3VsZCB0aGlzIG1vZHVsZSBjaGFuZ2UgdGhlIG1lbW9y
eSBhbGxvY2F0aW9uIGludG8gdm1hbGxvYyA/DQp0aGUgYnVmZmVyIGFsbG9jYXRlZCBieSB2bWFs
bG9jIGNhbiBub3QgYmUgdXNlZCBmb3IgdGhlIERNQS4NCg0KSSB0aGluayB0aGF0J3Mgd2h5IGRy
aXZlcnMgdXNlIHRoZSBrbWFsbG9jLg0KDQp0aGFua3MNCkh1YW5nIFNoaWppZQ0KDQpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpBbHNhLWRldmVsIG1haWxp
bmcgbGlzdApBbHNhLWRldmVsQGFsc2EtcHJvamVjdC5vcmcKaHR0cDovL21haWxtYW4uYWxzYS1w
cm9qZWN0Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Fsc2EtZGV2ZWwK
