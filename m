From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: unmet direct dependencies (NET && NET_SCHED)
Date: Wed, 5 Jan 2011 14:22:20 +0100
Message-ID: <201101051422.20490.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

a "make randconfig 1>/dev/null" gave today :

tfoerste@n22 ~/devel/linux-2.6 $ make randconfig 1>/dev/null
warning: (NETFILTER_XT_MATCH_REALM && NET && INET && NETFILTER &&=20
NETFILTER_XTABLES && NETFILTER_ADVANCED || NET_CLS_ROUTE4 && NET && NET=
_SCHED)=20
selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_S=
CHED)

for the current git kernel sources.
Is this an already known issue ?

--=20
MfG/Kind regards
Toralf F=C3=B6rster

pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

