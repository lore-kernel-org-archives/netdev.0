From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: skbedit action chaining with other actions - will fail
Date: Sun, 8 Mar 2009 02:20:54 +0200
Message-ID: <200903080220.55055.denys@visp.net.lb>
References: <200903080115.41617.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, shemminger@osdl.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52954 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbZCHAVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 19:21:00 -0500
In-Reply-To: <200903080115.41617.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry my mistake, discard

It should be
     echo "filter add dev $2 parent ffff: protocol ip prio 10 u32 \
 match u32 0 0 flowid 1:1 \
 action skbedit priority 0x${lowid} pipe \
 action mirred egress redirect dev ifb0"

(i forgot pipe)

ipt use another way of defining action (depends on return value of iptables).
