From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 06/12] audit: Use timespec64 to represent audit
	timestamps
Date: Tue, 11 Apr 2017 16:12:02 -0400
Message-ID: <CAHC9VhTMU7cEJD2rffxOshEnL18i597GBsvHZm-Y8hCE9SJCAA@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-7-git-send-email-deepa.kernel@gmail.com>
 <CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
 <CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: yuchao0@huawei.com, "J. Bruce Fields" <bfields@fieldses.org>,
 Chris Mason <clm@fb.com>, linux-mtd <linux-mtd@lists.infradead.org>,
 Evgeniy Dushistov <dushistov@mail.ru>, Jeff Layton <jlayton@poochiereds.net>,
 ceph-devel <ceph-devel@vger.kernel.org>, devel@driverdev.osuosl.org,
 linux-cifs@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>,
 Ingo Molnar <mingo@redhat.com>, James Simmons <jsimmons@infradead.org>,
 Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>,
 oleg.drokin@intel.com, John Stultz <john.stultz@linaro.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.com>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 andreas.dilger@intel.com, Josef Bacik <jbacik@fb.com>,
 Greg KH <gregkh@linuxfoundation.org>, samba-technical@lists.samba.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
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

T24gU2F0LCBBcHIgOCwgMjAxNyBhdCAxOjU4IFBNLCBEZWVwYSBEaW5hbWFuaSA8ZGVlcGEua2Vy
bmVsQGdtYWlsLmNvbT4gd3JvdGU6Cj4+IEkgaGF2ZSBubyBwcm9ibGVtIG1lcmdpbmcgdGhpcyBw
YXRjaCBpbnRvIGF1ZGl0L25leHQgZm9yIHY0LjEyLCB3b3VsZAo+PiB5b3UgcHJlZmVyIG1lIHRv
IGRvIHRoYXQgc28gYXQgbGVhc3QgdGhpcyBwYXRjaCBpcyBtZXJnZWQ/Cj4KPiBUaGlzIHdvdWxk
IGJlIGZpbmUuCj4gQnV0LCBJIHRoaW5rIHdob2V2ZXIgdGFrZXMgdGhlIGxhc3QgMiBkZWxldGlv
biBwYXRjaGVzIHNob3VsZCBhbHNvIHRha2UgdGhlbS4KPiBJJ20gbm90IHN1cmUgaG93IHRoYXQg
cGFydCB3b3JrcyBvdXQuCgpGV0lXLCBJIGp1c3QgbWVyZ2VkIHRoaXMgaW50byB0aGUgYXVkaXQv
bmV4dCBicmFuY2ggc28gYXQgbGVhc3QgdGhpcwp3aWxsIGdvIGludG8gdjQuMTIuCgo+PiBJdCB3
b3VsZCBwcm9iYWJseSBtYWtlIGxpZmUgYSBzbWFsbCBiaXQgZWFzaWVyIGZvciB1cyBpbiB0aGUg
YXVkaXQKPj4gd29ybGQgdG9vIGFzIGl0IHdvdWxkIHJlZHVjZSB0aGUgcG90ZW50aWFsIG1lcmdl
IGNvbmZsaWN0LiAgSG93ZXZlciwKPj4gdGhhdCdzIGEgcmVsYXRpdmVseSBzbWFsbCB0aGluZyB0
byB3b3JyeSBhYm91dC4KCi0tIApwYXVsIG1vb3JlCnd3dy5wYXVsLW1vb3JlLmNvbQpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5nIGxp
c3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFpbG1h
bi9saXN0aW5mby95MjAzOAo=
