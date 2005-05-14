From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: remove extra __ip_vs_conn_put for incoming ICMP
Date: Sat, 14 May 2005 10:57:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0505141037430.1568@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-1685291764-1116057446=:1568"
Cc: netdev@oss.sgi.com, Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-1685291764-1116057446=:1568
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	Dave, please apply a patch against 2.6.12-rc4

	Remove extra __ip_vs_conn_put for incoming ICMP in direct routing
mode. Mark de Vries reports that IPVS connections are not leaked anymore.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

--1607745702-1685291764-1116057446=:1568
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="icmp_xmit.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0505141057260.1568@u.domain.uli>
Content-Description: Fix ICMP xmit
Content-Disposition: attachment; filename="icmp_xmit.diff"

ZGlmZiAtdXIgdjIuNi4xMi1yYzQvbGludXgvbmV0L2lwdjQvaXB2cy9pcF92
c194bWl0LmMgbGludXgvbmV0L2lwdjQvaXB2cy9pcF92c194bWl0LmMNCi0t
LSB2Mi42LjEyLXJjNC9saW51eC9uZXQvaXB2NC9pcHZzL2lwX3ZzX3htaXQu
YwkyMDA0LTA4LTMxIDA4OjA5OjMxLjAwMDAwMDAwMCArMDMwMA0KKysrIGxp
bnV4L25ldC9pcHY0L2lwdnMvaXBfdnNfeG1pdC5jCTIwMDUtMDUtMDkgMDA6
MzE6NDcuODEwODA3MjMyICswMzAwDQpAQCAtNTIwLDcgKzUyMCw2IEBADQog
CQkJcmMgPSBORl9BQ0NFUFQ7DQogCQkvKiBkbyBub3QgdG91Y2ggc2tiIGFu
eW1vcmUgKi8NCiAJCWF0b21pY19pbmMoJmNwLT5pbl9wa3RzKTsNCi0JCV9f
aXBfdnNfY29ubl9wdXQoY3ApOw0KIAkJZ290byBvdXQ7DQogCX0NCiANCg==

--1607745702-1685291764-1116057446=:1568--
