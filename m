From: John Johansen <john.johansen@canonical.com>
Subject: Re: [PATCH 10/12] apparmorfs: Replace CURRENT_TIME with
 current_time()
Date: Fri, 2 Jun 2017 00:29:48 -0700
Message-ID: <b5d3d600-d3fe-669f-f6bc-01dcedbb7fe3@canonical.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-11-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: yuchao0@huawei.com, bfields@fieldses.org, clm@fb.com,
 linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net,
 tglx@linutronix.de, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org,
 paul@paul-moore.com, y2038@lists.linaro.org, mingo@redhat.com,
 jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org,
 oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk,
 dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org,
 andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org,
 samba-technical@lists.samba.org, eparis@redhat.com,
 linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 davem@davemloft.net, linux-btrfs@vger.kernel.org,
 lustre-devel@lists.lustre.org
To: Deepa Dinamani <deepa.kernel@gmail.com>, linux-kernel@vger.kernel.org,
 akpm@linux-foundation.org
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1491613030-11599-11-git-send-email-deepa.kernel@gmail.com>
Content-Language: en-GB
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

T24gMDQvMDcvMjAxNyAwNTo1NyBQTSwgRGVlcGEgRGluYW1hbmkgd3JvdGU6Cj4gQ1VSUkVOVF9U
SU1FIG1hY3JvIGlzIG5vdCB5MjAzOCBzYWZlIG9uIDMyIGJpdCBzeXN0ZW1zLgo+IAo+IFRoZSBw
YXRjaCByZXBsYWNlcyBhbGwgdGhlIHVzZXMgb2YgQ1VSUkVOVF9USU1FIGJ5Cj4gY3VycmVudF90
aW1lKCkuCj4gCj4gVGhpcyBpcyBhbHNvIGluIHByZXBhcmF0aW9uIGZvciB0aGUgcGF0Y2ggdGhh
dCB0cmFuc2l0aW9ucwo+IHZmcyB0aW1lc3RhbXBzIHRvIHVzZSA2NCBiaXQgdGltZSBhbmQgaGVu
Y2UgbWFrZSB0aGVtCj4geTIwMzggc2FmZS4gY3VycmVudF90aW1lKCkgaXMgYWxzbyBwbGFubmVk
IHRvIGJlIHRyYW5zaXRpb25lZAo+IHRvIHkyMDM4IHNhZmUgYmVoYXZpb3IgYWxvbmcgd2l0aCB0
aGlzIGNoYW5nZS4KPiAKPiBDVVJSRU5UX1RJTUUgbWFjcm8gd2lsbCBiZSBkZWxldGVkIGJlZm9y
ZSBtZXJnaW5nIHRoZQo+IGFmb3JlbWVudGlvbmVkIGNoYW5nZS4KPiAKPiBTaWduZWQtb2ZmLWJ5
OiBEZWVwYSBEaW5hbWFuaSA8ZGVlcGEua2VybmVsQGdtYWlsLmNvbT4KClRoaXMgaXMgYWxsIGdv
b2QsIGFuZCBJIGhhdmUgbm8gb2JqZWN0aW9ucyB0byBpdCBiZWluZyBtZXJnZWQgZm9yIDQuMTIu
CklmIGl0IGlzbid0IHRoaXMgY2hhbmdlIGlzIGFscmVhZHkgcXVldWVkIHVwIGZvciB0aGUgYXBw
YXJtb3IgNC4xMwptZXJnZQoKQWNrZWQtYnk6IEpvaG4gSm9oYW5zZW4gPGpvaG4uam9oYW5zZW5A
Y2Fub25pY2FsLmNvbT4KCj4gLS0tCj4gIHNlY3VyaXR5L2FwcGFybW9yL2FwcGFybW9yZnMuYyB8
IDIgKy0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4g
Cj4gZGlmZiAtLWdpdCBhL3NlY3VyaXR5L2FwcGFybW9yL2FwcGFybW9yZnMuYyBiL3NlY3VyaXR5
L2FwcGFybW9yL2FwcGFybW9yZnMuYwo+IGluZGV4IGJlMGI0OTguLjRmNmFjOWQgMTAwNjQ0Cj4g
LS0tIGEvc2VjdXJpdHkvYXBwYXJtb3IvYXBwYXJtb3Jmcy5jCj4gKysrIGIvc2VjdXJpdHkvYXBw
YXJtb3IvYXBwYXJtb3Jmcy5jCj4gQEAgLTEzNTcsNyArMTM1Nyw3IEBAIHN0YXRpYyBpbnQgYWFf
bWtfbnVsbF9maWxlKHN0cnVjdCBkZW50cnkgKnBhcmVudCkKPiAgCj4gIAlpbm9kZS0+aV9pbm8g
PSBnZXRfbmV4dF9pbm8oKTsKPiAgCWlub2RlLT5pX21vZGUgPSBTX0lGQ0hSIHwgU19JUlVHTyB8
IFNfSVdVR087Cj4gLQlpbm9kZS0+aV9hdGltZSA9IGlub2RlLT5pX210aW1lID0gaW5vZGUtPmlf
Y3RpbWUgPSBDVVJSRU5UX1RJTUU7Cj4gKwlpbm9kZS0+aV9hdGltZSA9IGlub2RlLT5pX210aW1l
ID0gaW5vZGUtPmlfY3RpbWUgPSBjdXJyZW50X3RpbWUoaW5vZGUpOwo+ICAJaW5pdF9zcGVjaWFs
X2lub2RlKGlub2RlLCBTX0lGQ0hSIHwgU19JUlVHTyB8IFNfSVdVR08sCj4gIAkJCSAgIE1LREVW
KE1FTV9NQUpPUiwgMykpOwo+ICAJZF9pbnN0YW50aWF0ZShkZW50cnksIGlub2RlKTsKPiAKCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClkyMDM4IG1haWxp
bmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
