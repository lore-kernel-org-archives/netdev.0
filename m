From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH v4 00/25] Convert the posix_clock_operations and
 k_clock structure to ready for 2038
Date: Wed, 3 Jun 2015 10:13:24 +0800
Message-ID: <CAMz4ku+8unOm7EpZyurO+mzUywTJWJng_NFMAfcD8jPMHQAneg@mail.gmail.com>
References: <1433159093-4548-1-git-send-email-baolin.wang@linaro.org>
 <alpine.DEB.2.11.1506022115240.20347@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
 benh@kernel.crashing.org, heiko.carstens@de.ibm.com, paulus@samba.org,
 Jeffrey Vander Stoep <jeffv@google.com>, cl@linux.com, mark.d.rustad@intel.com,
 Heena Sirwani <heenasirwani@gmail.com>, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>,
 mpe@ellerman.id.au, rafael.j.wysocki@intel.com, Andrew Hunter <ahh@google.com>,
 tiwai@suse.de, Jeffrey Layton <jlayton@primarydata.com>,
 =?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
 Paul Turner <pjt@google.com>, serge@hallyn.com,
 Serge Hallyn <serge.hallyn@canonical.com>, riel@redhat.com,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Richard Cochran <richardcochran@gmail.com>, schwidefsky@de.ibm.com,
 John Stultz <john.stultz@linaro.org>, james.l.morris@oracle.com,
 rth@twiddle.net, sds@tyc
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <alpine.DEB.2.11.1506022115240.20347@nanos>
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

T24gMyBKdW5lIDIwMTUgYXQgMDM6MjAsIFRob21hcyBHbGVpeG5lciA8dGdseEBsaW51dHJvbml4
LmRlPiB3cm90ZToKCj4gT24gTW9uLCAxIEp1biAyMDE1LCBCYW9saW4gV2FuZyB3cm90ZToKPgo+
ID4gVGhpcyBwYXRjaCBzZXJpZXMgY2hhbmdlcyB0aGUgMzItYml0IHRpbWUgdHlwZXMgKHRpbWVz
cGVjL2l0aW1lcnNwZWMpIHRvCj4gPiB0aGUgNjQtYml0IHR5cGVzICh0aW1lc3BlYzY0L2l0aW1l
cnNwZWM2NCksIHNpbmNlIDMyLWJpdCB0aW1lIHR5cGVzIHdpbGwKPiA+IGJyZWFrIGluIHRoZSB5
ZWFyIDIwMzguCj4KPiBUaGF0J3Mgb25seSB0cnVlIGZvciAzMmJpdCBzeXN0ZW1zLgo+Cj4gQWxs
IGluIGFsbCB0aGUgcGF0Y2ggc2VyaWVzIGxvb2tzIHJhdGhlciByZWFzb25hYmxlIG5vdywgZXhj
ZXB0IGZvcgo+IHRoZSBzdWJqZWN0IGxpbmVzIGFuZCB0aGUgY2hhbmdlbG9ncy4KPgo+IFRoZSBv
bmx5IHRlY2huaWNhbCBvYmplY3Rpb24gSSBoYXZlIGlzIHRoZSBtYWNybyBjb252ZXJzaW9uIG1h
Z2ljIGluCj4gcGF0Y2ggIzYuIFRoaXMgY2FuIGJlIGRvbmUgaW4gYSBsZXNzIGNyeXB0aWMgYW5k
IG1vcmUgZWZmaWNpZW50IHdheS4KPgo+IFNlZSB0aGUgY29tbWVudHMgdG8gdGhlIHZhcmlvdXMg
cGF0Y2hlcyBhbmQgcGxlYXNlIGFwcGx5IHRoZW0gdG8gYWxsCj4gb2YgdGhlIHNlcmllcy4KPgo+
IFRoYW5rcywKPgo+ICAgICAgICAgdGdseAo+Cj4KPgpIaSBUaG9tYXMsCgpUaGFua3MgZm9yIHlv
dXIgY29tbWVudHMsIGFuZCBpJ2xsIGNoZWNrIGFuZCBmaXggdGhlc2UgcHJvYmxlbXMuCgotLSAK
QmFvbGluLndhbmcKQmVzdCBSZWdhcmRzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fClkyMDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3Jn
Cmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
