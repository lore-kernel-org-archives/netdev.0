From: Burton Windle <bwindle@fint.org>
Subject: Trivial patch for printk in tcp_input.c
Date: Thu, 24 Jun 2004 13:02:12 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406241255110.921@morpheus>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-499955320-1088096532=:921"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--8323328-499955320-1088096532=:921
Content-Type: TEXT/PLAIN; charset=US-ASCII

Here is a trivial patch to add a newline at the end of a printk in
tcp_input.c.

patch is against 2.6.7.

Without this patch, the output of the printk in question looks like this:

tcp_parse_options: Illegal window scaling value 255 >14 received.tcp_parse_options: Illegal window scaling value 255 >14
received.tcp_parse_options: Illegal window scaling value 255 >14 received.tcp_parse_options: Illegal window scaling value 255 >14 received.

It might be nice if this printk told us where the packet came from, but
I'll save that for another patch.

--
Burton Windle                           bwindle@fint.org

--8323328-499955320-1088096532=:921
Content-Type: TEXT/plain; charset=US-ASCII; name="tcp_input_printk_fix.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0406241302120.921@morpheus>
Content-Description: fix newline in printk
Content-Disposition: attachment; filename="tcp_input_printk_fix.diff"

LS0tIGxpbnV4L25ldC9pcHY0L3RjcF9pbnB1dC5jCTIwMDQtMDYtMTYgMTE6
MzM6MTYuMDAwMDAwMDAwIC0wNDAwDQorKysgbGludXgtYncvbmV0L2lwdjQv
dGNwX2lucHV0LmMJMjAwNC0wNi0yNCAxMjo1MzowNi4wMDAwMDAwMDAgLTA0
MDANCkBAIC0yOTE5LDcgKzI5MTksNyBAQA0KIAkJCQkJCQlpZih0cC0+c25k
X3dzY2FsZSA+IDE0KSB7DQogCQkJCQkJCQlpZihuZXRfcmF0ZWxpbWl0KCkp
DQogCQkJCQkJCQkJcHJpbnRrKCJ0Y3BfcGFyc2Vfb3B0aW9uczogSWxsZWdh
bCB3aW5kb3cgIg0KLQkJCQkJCQkJCSAgICAgICAic2NhbGluZyB2YWx1ZSAl
ZCA+MTQgcmVjZWl2ZWQuIiwNCisJCQkJCQkJCQkgICAgICAgInNjYWxpbmcg
dmFsdWUgJWQgPjE0IHJlY2VpdmVkLlxuIiwNCiAJCQkJCQkJCQkgICAgICAg
dHAtPnNuZF93c2NhbGUpOw0KIAkJCQkJCQkJdHAtPnNuZF93c2NhbGUgPSAx
NDsNCiAJCQkJCQkJfQ0K

--8323328-499955320-1088096532=:921--
