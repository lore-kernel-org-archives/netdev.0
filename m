From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH 2/3] fs: poll/select/recvmmsg: use
 timespec64 for timeout events
Date: Wed, 4 May 2016 16:51:15 -0700
Message-ID: <20160504165115.e0247881921fdcd0af4a394c@linux-foundation.org>
References: <1461947989-21926-3-git-send-email-deepa.kernel@gmail.com>
 <1462389899-2480-1-git-send-email-deepa.kernel@gmail.com>
 <CALAqxLVB8XiRrFKxK3GzBxw-CfEmC=Dh-CrTOEqT144ngZg-Dw@mail.gmail.com>
 <4256673.7Gok2HNpOM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arjan van de Ven <arjan@linux.intel.com>,
 Eliezer Tamir <eliezer.tamir@linux.intel.com>, y2038@lists.linaro.org,
 netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, John Stultz <john.stultz@linaro.org>,
 Deepa Dinamani <deepa.kernel@gmail.com>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "David S. Miller" <davem@davemloft.net>,
 Alexander Viro <viro@zeniv.linux.org.uk>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <4256673.7Gok2HNpOM@wuerfel>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

T24gV2VkLCAwNCBNYXkgMjAxNiAyMzowODoxMSArMDIwMCBBcm5kIEJlcmdtYW5uIDxhcm5kQGFy
bmRiLmRlPiB3cm90ZToKCj4gPiBCdXQgSSdtIGxlc3MgY29tZm9ydGFibGUgbWFraW5nIHRoZSBj
YWxsIG9uIHRoaXMgb25lLiBJdCBsb29rcwo+ID4gcmVsYXRpdmVseSBzdHJhaWdodCBmb3J3YXJk
LCBidXQgaXQgd291bGQgYmUgZ29vZCB0byBoYXZlIG1haW50YWluZXIKPiA+IGFja3MgYmVmb3Jl
IEkgYWRkIGl0IHRvIG15IHRyZWUuCj4gCj4gQWdyZWVkLiBGZWVsIGZyZWUgdG8gYWRkIG15Cj4g
Cj4gUmV2aWV3ZWQtYnk6IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+Cj4gCj4gYXQgbGVh
c3QgKHdob2V2ZXIgcGlja3MgaXQgdXApLgoKSW4gcmVwbHkgdG8gWzEvM10gSm9obiBzYWlkCgo6
IExvb2tzIG9rIGF0IHRoZSBmaXJzdCBnbGFuY2UuIEkndmUgcXVldWVkIHRoZXNlIHVwIGZvciB0
ZXN0aW5nLAo6IGhvd2V2ZXIgSSBvbmx5IGdvdCAjMSBhbmQgIzMgb2YgdGhlIHNldC4gQXJlIHlv
dSBob3BpbmcgdGhlc2UgdHdvCjogcGF0Y2hlcyB3aWxsIGdvIHRocm91Z2ggdGlwL3RpbWVycy9j
b3JlIG9yIGFyZSB5b3UgbG9va2luZyBmb3IgYWNrcyBzbwo6IHRoZXkgY2FuIGdvIHZpYSBhbm90
aGVyIHRyZWU/CgpIb3dldmVyIG5vbmUgb2YgdGhlIHBhdGNoZXMgYXJlIGluIGxpbnV4LW5leHQu
CgpKb2huIGhhZCBxdWFsbXMgYWJvdXQgWzIvM10sIGJ1dCBpdCBsb29rcyBsaWtlIGEgc3RyYWln
aHRmb3J3YXJkCnN1YnN0aXR1dGlvbiBpbiBhcmVhcyB3aGljaCB3aWxsIGdldCBwbGVudHkgb2Yg
dGVzdGluZwoKSSdsbCBncmFiIHRoZSBwYXRjaGVzIGZvciBub3cgdG8gZ2V0IHRoZW0gc29tZSBl
eHRlcm5hbCB0ZXN0aW5nLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczov
L2xpc3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
