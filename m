From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] Trivial fix for out of bounds array access in xfrm4_policy_check
Date: Tue, 7 Sep 2004 13:35:52 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0409071322100.8637@hosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1646943047-1948299716-1094553352=:8637"
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-1948299716-1094553352=:8637
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

Hello!

Coverity found a bug in accessing xfrm4_policy_check using XFRM_POLICY_FWD 
(=2) as index in sk->sk_policy.

sk->sk_policy[] is defined in sock.h as:

struct xfrm_policy *sk_policy[2];

Attached is the fix.

http://linuxbugs.coverity.com/external/editbugparent.php?viewbugid=2138&checkers%5B%5D=all&status%5B%5D=BUG&status%5B%5D=UNINSPECTED&status%5B%5D=UNKNOWN&status%5B%5D=DON%27T%20CARE&status%5B%5D=PENDING&product%5B%5D=all&component%5B%5D=all&file=&fn=&sortby=reverse_rank&before=&after=&curpage=2&bugid=-1&comment=&reason=

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-1948299716-1094553352=:8637
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="out-of-bounds-xfrm_policy.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0409071335520.8637@hosting.rdsbv.ro>
Content-Description: 
Content-Disposition: attachment; filename="out-of-bounds-xfrm_policy.patch"

LS0tIGxpbnV4L2luY2x1ZGUvbmV0L3NvY2suaAkyMDA0LTA5LTA3IDEzOjEz
OjMxLjAwMDAwMDAwMCArMDMwMA0KKysrIG15bGludXgvaW5jbHVkZS9uZXQv
c29jay5oCTIwMDQtMDktMDcgMTM6MTQ6MzYuMDAwMDAwMDAwICswMzAwDQpA
QCAtMjAxLDcgKzIwMSw3IEBAIHN0cnVjdCBzb2NrIHsNCiAJd2FpdF9xdWV1
ZV9oZWFkX3QJKnNrX3NsZWVwOw0KIAlzdHJ1Y3QgZHN0X2VudHJ5CSpza19k
c3RfY2FjaGU7DQogCXJ3bG9ja190CQlza19kc3RfbG9jazsNCi0Jc3RydWN0
IHhmcm1fcG9saWN5CSpza19wb2xpY3lbMl07DQorCXN0cnVjdCB4ZnJtX3Bv
bGljeQkqc2tfcG9saWN5WzNdOw0KIAlhdG9taWNfdAkJc2tfcm1lbV9hbGxv
YzsNCiAJc3RydWN0IHNrX2J1ZmZfaGVhZAlza19yZWNlaXZlX3F1ZXVlOw0K
IAlhdG9taWNfdAkJc2tfd21lbV9hbGxvYzsNCg==

---1646943047-1948299716-1094553352=:8637--
