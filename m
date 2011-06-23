From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 4/5] pm: move pm notifiers into suspend.h
Date: Thu, 23 Jun 2011 13:03:54 +0800
Message-ID: <4E02C93A.7010601@redhat.com>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com> <1308724522-32461-5-git-send-email-amwang@redhat.com> <201106222149.28252.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040106060502030605060003"
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, Chris Ball <cjb@laptop.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Philip Rakity <prakity@marvell.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	linux-mmc@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <201106222149.28252.rjw@sisk.pl>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040106060502030605060003
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

于 2011年06月23日 03:49, Rafael J. Wysocki 写道:
>> +#ifdef CONFIG_PM
>> >  +#include<linux/suspend.h>
>> >  +#endif
> I don't think the #ifdef in necessary.  Any dependencies on CONFIG_PM
> (or CONFIG_SUSPEND etc.) should be taken care of inside of suspend.h.
> This file should be fixed if they aren't.
>

Ok, please check the updated version below.

Thanks.


--------------040106060502030605060003
Content-Type: text/plain;
 name="pm-move-pm-notifiers-into-suspend.h.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="pm-move-pm-notifiers-into-suspend.h.patch"

QXV0aG9yOiBBbWVyaWdvIFdhbmcgPGFtd2FuZ0ByZWRoYXQuY29tPgoKICAgIHBtOiBtb3Zl
IHBtIG5vdGlmaWVycyBpbnRvIHN1c3BlbmQuaAoKU2lnbmVkLW9mZi1ieTogV0FORyBDb25n
IDxhbXdhbmdAcmVkaGF0LmNvbT4KCi0tLQpkaWZmIC0tZ2l0IGEvZHJpdmVycy9tbWMvY29y
ZS9jb3JlLmMgYi9kcml2ZXJzL21tYy9jb3JlL2NvcmUuYwppbmRleCA2ODA5MWRkLi41MDNk
YmM5IDEwMDY0NAotLS0gYS9kcml2ZXJzL21tYy9jb3JlL2NvcmUuYworKysgYi9kcml2ZXJz
L21tYy9jb3JlL2NvcmUuYwpAQCAtMjMsNiArMjMsNyBAQAogI2luY2x1ZGUgPGxpbnV4L2xv
ZzIuaD4KICNpbmNsdWRlIDxsaW51eC9yZWd1bGF0b3IvY29uc3VtZXIuaD4KICNpbmNsdWRl
IDxsaW51eC9wbV9ydW50aW1lLmg+CisjaW5jbHVkZSA8bGludXgvc3VzcGVuZC5oPgogCiAj
aW5jbHVkZSA8bGludXgvbW1jL2NhcmQuaD4KICNpbmNsdWRlIDxsaW51eC9tbWMvaG9zdC5o
PgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9ub3RpZmllci5oIGIvaW5jbHVkZS9saW51
eC9ub3RpZmllci5oCmluZGV4IDE0NWM0MzYuLmFlOGY3ZDkgMTAwNjQ0Ci0tLSBhL2luY2x1
ZGUvbGludXgvbm90aWZpZXIuaAorKysgYi9pbmNsdWRlL2xpbnV4L25vdGlmaWVyLmgKQEAg
LTE5MSwxNSArMTkxLDkgQEAgc3RhdGljIGlubGluZSBpbnQgbm90aWZpZXJfdG9fZXJybm8o
aW50IHJldCkKIAogLyogcmVib290IG5vdGlmaWVycyBhcmUgZGVmaW5lZCBpbiBpbmNsdWRl
L2xpbnV4L3JlYm9vdC5oLiAqLwogCi0jZGVmaW5lIE5FVExJTktfVVJFTEVBU0UJMHgwMDAx
CS8qIFVuaWNhc3QgbmV0bGluayBzb2NrZXQgcmVsZWFzZWQgKi8KKy8qIEhpYmVybmF0aW9u
IGFuZCBzdXNwZW5kIGV2ZW50cyBhcmUgZGVmaW5lZCBpbiBpbmNsdWRlL2xpbnV4L3N1c3Bl
bmQuaC4gKi8KIAotLyogSGliZXJuYXRpb24gYW5kIHN1c3BlbmQgZXZlbnRzICovCi0jZGVm
aW5lIFBNX0hJQkVSTkFUSU9OX1BSRVBBUkUJMHgwMDAxIC8qIEdvaW5nIHRvIGhpYmVybmF0
ZSAqLwotI2RlZmluZSBQTV9QT1NUX0hJQkVSTkFUSU9OCTB4MDAwMiAvKiBIaWJlcm5hdGlv
biBmaW5pc2hlZCAqLwotI2RlZmluZSBQTV9TVVNQRU5EX1BSRVBBUkUJMHgwMDAzIC8qIEdv
aW5nIHRvIHN1c3BlbmQgdGhlIHN5c3RlbSAqLwotI2RlZmluZSBQTV9QT1NUX1NVU1BFTkQJ
CTB4MDAwNCAvKiBTdXNwZW5kIGZpbmlzaGVkICovCi0jZGVmaW5lIFBNX1JFU1RPUkVfUFJF
UEFSRQkweDAwMDUgLyogR29pbmcgdG8gcmVzdG9yZSBhIHNhdmVkIGltYWdlICovCi0jZGVm
aW5lIFBNX1BPU1RfUkVTVE9SRQkJMHgwMDA2IC8qIFJlc3RvcmUgZmFpbGVkICovCisjZGVm
aW5lIE5FVExJTktfVVJFTEVBU0UJMHgwMDAxCS8qIFVuaWNhc3QgbmV0bGluayBzb2NrZXQg
cmVsZWFzZWQgKi8KIAogLyogQ29uc29sZSBrZXlib2FyZCBldmVudHMuCiAgKiBOb3RlOiBL
QkRfS0VZQ09ERSBpcyBhbHdheXMgc2VudCBiZWZvcmUgS0JEX1VOQk9VTkRfS0VZQ09ERSwg
S0JEX1VOSUNPREUgYW5kCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L3N1c3BlbmQuaCBi
L2luY2x1ZGUvbGludXgvc3VzcGVuZC5oCmluZGV4IDA4M2ZmZWEuLjk1YmM4MWMgMTAwNjQ0
Ci0tLSBhL2luY2x1ZGUvbGludXgvc3VzcGVuZC5oCisrKyBiL2luY2x1ZGUvbGludXgvc3Vz
cGVuZC5oCkBAIC0yNjAsNiArMjYwLDE0IEBAIHN0YXRpYyBpbmxpbmUgaW50IGhpYmVybmF0
ZSh2b2lkKSB7IHJldHVybiAtRU5PU1lTOyB9CiBzdGF0aWMgaW5saW5lIGJvb2wgc3lzdGVt
X2VudGVyaW5nX2hpYmVybmF0aW9uKHZvaWQpIHsgcmV0dXJuIGZhbHNlOyB9CiAjZW5kaWYg
LyogQ09ORklHX0hJQkVSTkFUSU9OICovCiAKKy8qIEhpYmVybmF0aW9uIGFuZCBzdXNwZW5k
IGV2ZW50cyAqLworI2RlZmluZSBQTV9ISUJFUk5BVElPTl9QUkVQQVJFCTB4MDAwMSAvKiBH
b2luZyB0byBoaWJlcm5hdGUgKi8KKyNkZWZpbmUgUE1fUE9TVF9ISUJFUk5BVElPTgkweDAw
MDIgLyogSGliZXJuYXRpb24gZmluaXNoZWQgKi8KKyNkZWZpbmUgUE1fU1VTUEVORF9QUkVQ
QVJFCTB4MDAwMyAvKiBHb2luZyB0byBzdXNwZW5kIHRoZSBzeXN0ZW0gKi8KKyNkZWZpbmUg
UE1fUE9TVF9TVVNQRU5ECQkweDAwMDQgLyogU3VzcGVuZCBmaW5pc2hlZCAqLworI2RlZmlu
ZSBQTV9SRVNUT1JFX1BSRVBBUkUJMHgwMDA1IC8qIEdvaW5nIHRvIHJlc3RvcmUgYSBzYXZl
ZCBpbWFnZSAqLworI2RlZmluZSBQTV9QT1NUX1JFU1RPUkUJCTB4MDAwNiAvKiBSZXN0b3Jl
IGZhaWxlZCAqLworCiAjaWZkZWYgQ09ORklHX1BNX1NMRUVQCiB2b2lkIHNhdmVfcHJvY2Vz
c29yX3N0YXRlKHZvaWQpOwogdm9pZCByZXN0b3JlX3Byb2Nlc3Nvcl9zdGF0ZSh2b2lkKTsK

--------------040106060502030605060003--
