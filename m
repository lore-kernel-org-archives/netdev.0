From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sat, 29 Oct 2011 10:34:30 -0700
Message-ID: <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
References: <1319764761.23112.14.camel@edumazet-laptop> <20111028012521.GF25795@one.firstfloor.org>
 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
 <1319766293.6759.17.camel@deadeye> <1319770376.23112.58.camel@edumazet-laptop>
 <1319772566.6759.27.camel@deadeye> <1319777025.23112.67.camel@edumazet-laptop>
 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
 <1319803781.23112.113.camel@edumazet-laptop> <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
 <1319813252.23112.122.camel@edumazet-laptop> <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6dbde153dff8004b0736cee
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0016e6dbde153dff8004b0736cee
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Oct 28, 2011 at 7:55 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Comments? I think I'm open to tested patches..

Here's a *untested* patch.

In particular, I worry that I'd need to add a "#include
<linux/compiler.h>" to some header file, although I suspect it gets
included some way regardless.

And when I say "untested", I mean it. I verified that this makes
*some* difference to the generated code, but I didn't actually check
if it really matters, or if it actually compiles and works in general.

Caveat tester,

                                Linus

--0016e6dbde153dff8004b0736cee
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gucw3idn0

IGFyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oIHwgICAgNSArKystLQogaW5jbHVkZS9hc20t
Z2VuZXJpYy9hdG9taWMuaCAgfCAgICAyICstCiBpbmNsdWRlL2xpbnV4L2NvbXBpbGVyLmggICAg
ICB8ICAgIDcgKysrKysrKwogMyBmaWxlcyBjaGFuZ2VkLCAxMSBpbnNlcnRpb25zKCspLCAzIGRl
bGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oIGIv
YXJjaC94ODYvaW5jbHVkZS9hc20vYml0b3BzLmgKaW5kZXggMTc3NWQ2ZTU5MjBlLi5lMzk4MmNi
NDJmZTUgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oCisrKyBiL2Fy
Y2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oCkBAIC0zMDgsOCArMzA4LDkgQEAgc3RhdGljIGlu
bGluZSBpbnQgdGVzdF9hbmRfY2hhbmdlX2JpdChpbnQgbnIsIHZvbGF0aWxlIHVuc2lnbmVkIGxv
bmcgKmFkZHIpCiAKIHN0YXRpYyBfX2Fsd2F5c19pbmxpbmUgaW50IGNvbnN0YW50X3Rlc3RfYml0
KHVuc2lnbmVkIGludCBuciwgY29uc3Qgdm9sYXRpbGUgdW5zaWduZWQgbG9uZyAqYWRkcikKIHsK
LQlyZXR1cm4gKCgxVUwgPDwgKG5yICUgQklUU19QRVJfTE9ORykpICYKLQkJKGFkZHJbbnIgLyBC
SVRTX1BFUl9MT05HXSkpICE9IDA7CisJdW5zaWduZWQgbG9uZyAqd29yZCA9IChuciAvIEJJVFNf
UEVSX0xPTkcpICsgKHVuc2lnbmVkIGxvbmcgKilhZGRyOworCXVuc2lnbmVkIGxvbmcgYml0ID0g
MVVMIDw8IChuciAlIEJJVFNfUEVSX0xPTkcpOworCXJldHVybiAoYml0ICYgQUNDRVNTX0FUX01P
U1RfT05DRSgqd29yZCkpICE9IDA7CiB9CiAKIHN0YXRpYyBpbmxpbmUgaW50IHZhcmlhYmxlX3Rl
c3RfYml0KGludCBuciwgdm9sYXRpbGUgY29uc3QgdW5zaWduZWQgbG9uZyAqYWRkcikKZGlmZiAt
LWdpdCBhL2luY2x1ZGUvYXNtLWdlbmVyaWMvYXRvbWljLmggYi9pbmNsdWRlL2FzbS1nZW5lcmlj
L2F0b21pYy5oCmluZGV4IGUzNzk2M2MxZGY0ZC4uYzA1ZTIxZjdhOTg1IDEwMDY0NAotLS0gYS9p
bmNsdWRlL2FzbS1nZW5lcmljL2F0b21pYy5oCisrKyBiL2luY2x1ZGUvYXNtLWdlbmVyaWMvYXRv
bWljLmgKQEAgLTM5LDcgKzM5LDcgQEAKICAqIEF0b21pY2FsbHkgcmVhZHMgdGhlIHZhbHVlIG9m
IEB2LgogICovCiAjaWZuZGVmIGF0b21pY19yZWFkCi0jZGVmaW5lIGF0b21pY19yZWFkKHYpCSgq
KHZvbGF0aWxlIGludCAqKSYodiktPmNvdW50ZXIpCisjZGVmaW5lIGF0b21pY19yZWFkKHYpCUFD
Q0VTU19BVF9NT1NUX09OQ0UoKHYpLT5jb3VudGVyKQogI2VuZGlmCiAKIC8qKgpkaWZmIC0tZ2l0
IGEvaW5jbHVkZS9saW51eC9jb21waWxlci5oIGIvaW5jbHVkZS9saW51eC9jb21waWxlci5oCmlu
ZGV4IDMyMGQ2Yzk0ZmY4NC4uZDMwZmZjNjg1MjQxIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4
L2NvbXBpbGVyLmgKKysrIGIvaW5jbHVkZS9saW51eC9jb21waWxlci5oCkBAIC0zMDgsNCArMzA4
LDExIEBAIHZvaWQgZnRyYWNlX2xpa2VseV91cGRhdGUoc3RydWN0IGZ0cmFjZV9icmFuY2hfZGF0
YSAqZiwgaW50IHZhbCwgaW50IGV4cGVjdCk7CiAgKi8KICNkZWZpbmUgQUNDRVNTX09OQ0UoeCkg
KCoodm9sYXRpbGUgdHlwZW9mKHgpICopJih4KSkKIAorLyoKKyAqIExpa2UgQUNDRVNTX09OQ0Us
IGJ1dCBjYW4gYmUgb3B0aW1pemVkIGF3YXkgaWYgbm90aGluZyB1c2VzIHRoZSB2YWx1ZSwKKyAq
IGFuZC9vciBtZXJnZWQgd2l0aCBwcmV2aW91cyBub24tT05DRSBhY2Nlc3Nlcy4KKyAqLworI2Rl
ZmluZSBBQ0NFU1NfQVRfTU9TVF9PTkNFKHgpIFwKKwkoeyB0eXBlb2YoeCkgX195OyBhc20oIiI6
Ij1yIiAoX195KToiMCIgKHgpKTsgX195OyB9KQorCiAjZW5kaWYgLyogX19MSU5VWF9DT01QSUxF
Ul9IICovCg==
--0016e6dbde153dff8004b0736cee--
