From: devik <devik@cdi.cz>
Subject: HTB 2.6.0-test10 oops related patch
Date: Sat, 6 Dec 2003 15:18:37 +0100 (CET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.33.0312061512320.839-200000@devix>
References: <4371.1067710407@www6.gmx.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-564380524-1070720317=:839"
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
	<daniel.blueman@gmx.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <4371.1067710407@www6.gmx.net>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--8323328-564380524-1070720317=:839
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hello Dave,

I discovered reason of the first Daniel's OOPS. It is change
which was not forward-ported to 2.6.
It is attached. However other Daniel's oops (pppd detach
related) is of unknown reason yet. I tried to duplicate all
conditions but pppoe (have no pppoe device here) and I was able
to kill pppd with htb under full load with no problem.
I'll look into it again today.

-------------------------------
    Martin Devera aka devik
Linux kernel QoS/HTB maintainer
  http://luxik.cdi.cz/~devik/


--8323328-564380524-1070720317=:839
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="htb2.6fix.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0312061518370.839@devix>
Content-Description: 
Content-Disposition: attachment; filename="htb2.6fix.diff"

LS0tIHNjaF9odGIub2xkCVNhdCBEZWMgIDYgMTU6MDU6MjEgMjAwMw0KKysr
IHNjaF9odGIuYwlTYXQgRGVjICA2IDE1OjA1OjI0IDIwMDMNCkBAIC03MDMs
NyArNzAzLDcgQEANCiANCiAgICAgc2NoLT5xLnFsZW4rKzsNCiAgICAgc2No
LT5zdGF0cy5wYWNrZXRzKys7IHNjaC0+c3RhdHMuYnl0ZXMgKz0gc2tiLT5s
ZW47DQotICAgIEhUQl9EQkcoMSwxLCJodGJfZW5xX29rIGNsPSVYIHNrYj0l
cFxuIixjbD9jbC0+Y2xhc3NpZDowLHNrYik7DQorICAgIEhUQl9EQkcoMSwx
LCJodGJfZW5xX29rIGNsPSVYIHNrYj0lcFxuIiwoY2wgJiYgY2wgIT0gSFRC
X0RJUkVDVCk/Y2wtPmNsYXNzaWQ6MCxza2IpOw0KICAgICByZXR1cm4gTkVU
X1hNSVRfU1VDQ0VTUzsNCiB9DQogDQpAQCAtNzMxLDcgKzczMSw3IEBADQog
CSAgICBodGJfYWN0aXZhdGUgKHEsY2wpOw0KIA0KICAgICBzY2gtPnEucWxl
bisrOw0KLSAgICBIVEJfREJHKDEsMSwiaHRiX3JlcV9vayBjbD0lWCBza2I9
JXBcbiIsY2w/Y2wtPmNsYXNzaWQ6MCxza2IpOw0KKyAgICBIVEJfREJHKDEs
MSwiaHRiX3JlcV9vayBjbD0lWCBza2I9JXBcbiIsKGNsICYmIGNsICE9IEhU
Ql9ESVJFQ1QpP2NsLT5jbGFzc2lkOjAsc2tiKTsNCiAgICAgcmV0dXJuIE5F
VF9YTUlUX1NVQ0NFU1M7DQogfQ0KIA0KQEAgLTE0NzcsNyArMTQ3Nyw3IEBA
DQogCQljbC0+bWFnaWMgPSBIVEJfQ01BR0lDOw0KICNlbmRpZg0KIA0KLQkJ
LyogY3JlYXRlIGxlYWYgcWRpc2MgZWFybHkgYmVjYXVzZSBpdCB1c2VzIGtt
YWxsb2MoR1BGX0tFUk5FTCkNCisJCS8qIGNyZWF0ZSBsZWFmIHFkaXNjIGVh
cmx5IGJlY2F1c2UgaXQgdXNlcyBrbWFsbG9jKEdGUF9LRVJORUwpDQogCQkg
ICBzbyB0aGF0IGNhbid0IGJlIHVzZWQgaW5zaWRlIG9mIHNjaF90cmVlX2xv
Y2sNCiAJCSAgIC0tIHRoYW5rcyB0byBLYXJsaXMgUGVpc2VuaWVrcyAqLw0K
IAkJbmV3X3EgPSBxZGlzY19jcmVhdGVfZGZsdChzY2gtPmRldiwgJnBmaWZv
X3FkaXNjX29wcyk7DQo=
--8323328-564380524-1070720317=:839--
