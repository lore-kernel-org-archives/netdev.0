From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] [SCHED] Fix unlock spinlock in error path
Date: Mon, 16 May 2005 16:01:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505161555080.13294@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1646943047-1586944306-1116248155=:13294"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.62.0505161556200.13294@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-1586944306-1116248155=:13294
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Content-ID: <Pine.LNX.4.62.0505161556201.13294@webhosting.rdsbv.ro>

Hello!

In act_api.c::tcf_action_copy_stats, in error path (get_stats
returns < 0), the spinlock taken in gnet_stats_start_copy_compat
or gnet_stats_start_copy is not unlocked.

The attached patch fixes this.

Please, apply.

Thank you very much!

Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-1586944306-1116248155=:13294
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME=act_api_missing_unlock.patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0505161555550.13294@webhosting.rdsbv.ro>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=act_api_missing_unlock.patch

LS0tIGxpbnV4L25ldC9zY2hlZC9hY3RfYXBpLmMJMjAwNS0wMy0wMiAwOToz
ODozMy4wMDAwMDAwMDAgKzAyMDANCisrKyB0b3ZidWcvbmV0L3NjaGVkL2Fj
dF9hcGkuYwkyMDA1LTA0LTE1IDEzOjI3OjU0LjAwMDAwMDAwMCArMDMwMA0K
QEAgLTQwMSw3ICs0MDEsNyBAQCBpbnQgdGNmX2FjdGlvbl9jb3B5X3N0YXRz
KHN0cnVjdCBza19idWZmDQogDQogCWlmIChhLT5vcHMgIT0gTlVMTCAmJiBh
LT5vcHMtPmdldF9zdGF0cyAhPSBOVUxMKQ0KIAkJaWYgKGEtPm9wcy0+Z2V0
X3N0YXRzKHNrYiwgYSkgPCAwKQ0KLQkJCWdvdG8gZXJyb3V0Ow0KKwkJCWdv
dG8gZXJyb3V0X3N0b3Bfc3RhdHM7DQogDQogCWlmIChnbmV0X3N0YXRzX2Nv
cHlfYmFzaWMoJmQsICZoLT5ic3RhdHMpIDwgMCB8fA0KICNpZmRlZiBDT05G
SUdfTkVUX0VTVElNQVRPUg0KQEAgLTQxNSw2ICs0MTUsOSBAQCBpbnQgdGNm
X2FjdGlvbl9jb3B5X3N0YXRzKHN0cnVjdCBza19idWZmDQogDQogCXJldHVy
biAwOw0KIA0KK2Vycm91dF9zdG9wX3N0YXRzOg0KKwlnbmV0X3N0YXRzX2Zp
bmlzaF9jb3B5KCZkKTsNCisNCiBlcnJvdXQ6DQogCXJldHVybiAtMTsNCiB9
DQo=

---1646943047-1586944306-1116248155=:13294--
