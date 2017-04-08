From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [PATCH 06/12] audit: Use timespec64 to represent audit
	timestamps
Date: Sat, 8 Apr 2017 10:58:05 -0700
Message-ID: <CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-7-git-send-email-deepa.kernel@gmail.com>
 <CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
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
To: Paul Moore <paul@paul-moore.com>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
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

PiBJIGhhdmUgbm8gcHJvYmxlbSBtZXJnaW5nIHRoaXMgcGF0Y2ggaW50byBhdWRpdC9uZXh0IGZv
ciB2NC4xMiwgd291bGQKPiB5b3UgcHJlZmVyIG1lIHRvIGRvIHRoYXQgc28gYXQgbGVhc3QgdGhp
cyBwYXRjaCBpcyBtZXJnZWQ/CgpUaGlzIHdvdWxkIGJlIGZpbmUuCkJ1dCwgSSB0aGluayB3aG9l
dmVyIHRha2VzIHRoZSBsYXN0IDIgZGVsZXRpb24gcGF0Y2hlcyBzaG91bGQgYWxzbyB0YWtlIHRo
ZW0uCkknbSBub3Qgc3VyZSBob3cgdGhhdCBwYXJ0IHdvcmtzIG91dC4KCj4gSXQgd291bGQgcHJv
YmFibHkgbWFrZSBsaWZlIGEgc21hbGwgYml0IGVhc2llciBmb3IgdXMgaW4gdGhlIGF1ZGl0Cj4g
d29ybGQgdG9vIGFzIGl0IHdvdWxkIHJlZHVjZSB0aGUgcG90ZW50aWFsIG1lcmdlIGNvbmZsaWN0
LiAgSG93ZXZlciwKPiB0aGF0J3MgYSByZWxhdGl2ZWx5IHNtYWxsIHRoaW5nIHRvIHdvcnJ5IGFi
b3V0LgoKLURlZXBhCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fClkyMDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlz
dHMubGluYXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
