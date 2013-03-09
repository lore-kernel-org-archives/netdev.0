From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/2] ipip: Few ipip tunnel improvements.
Date: Fri,  8 Mar 2013 17:12:40 -0800
Message-ID: <1362791560-1767-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:58316 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759941Ab3CIBLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 20:11:40 -0500
Received: by mail-ob0-f198.google.com with SMTP id dn14so9325919obc.5
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 17:11:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few improvements which are already present in other tunneling
protocols implementations like gre and vxlan.

Pravin B Shelar (2):
  ipip: Use tunnel_ip_select_ident() for tunnel IP-Identification.
  ipip: capture inner headers during encapsulation

 net/ipv4/ipip.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)
