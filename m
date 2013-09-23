From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: iproute2 and libnl3?
Date: Mon, 23 Sep 2013 20:17:33 +0200
Message-ID: <524085BD.7070608@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:61778 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab3IWSRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 14:17:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen (and others),

I'm trying to move the functionality from a small user space tool I wro=
te for=20
listening to HSR Netlink messages into iproute2. The tool uses generic =
netlink=20
through libnl3.=20

It seems iproute2 uses libnl-1 though:

iphsr.c:325:6: warning: 'struct nl_sock' declared inside parameter list
iphsr.c:334:30: error: 'NL_AUTO_PORT' undeclared (first use in this fun=
ction)
iphsr.c:341:2: warning: implicit declaration of function 'nl_send_auto'
iphsr.c:417:2: warning: implicit declaration of function 'genl_ctrl_res=
olve_grp'
iphsr.c:424:2: warning: implicit declaration of function 'nl_socket_add=
_memberships'
iphsr.c:455:2: warning: implicit declaration of function 'nl_socket_all=
oc'
iphsr.c:463:2: warning: implicit declaration of function 'nl_socket_dis=
able_seq_check'

Are there alternatives to the above functionality in libnl-1, or do I n=
eed to=20
implement it myself (copy them from the libnl3 code perhaps)?


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
