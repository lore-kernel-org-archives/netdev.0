From: "JUNG, Christian" <christian.jung@saarstahl.com>
Subject: Re: bonding: bug in balance-alb mode (incorrect update-ARP-replie
	 s)
Date: Mon, 29 Jan 2007 19:32:30 +0100
Message-ID: <FA8270F9F8D35946ADDBC0F36E6667CE03B23D63@nts27.saarstahl.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sag2.saarstahl.de ([62.154.234.163]:1081 "HELO
	ig01.int.saarstahl.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1752556AbXA2Scf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 13:32:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Jay Vosburgh wrote:
>
> 	Well, I meant other traffic that causes the ARP replies to be
> generated (i.e., concurrent traffic with the system).

No - there wasn't any concurrent network traffic. The system on which 
I've made the tcpdump had only the SSH-traffic to my box and no 
traffic to the system where the bond was running.

> 	There are some other issues with the rx hashtbl that have come
> up from my poking around, largely that it never, ever removes an entry
> from the table.  After a sufficient number of different clients have

A kind of aging would be hip.

Is it easy for you to (shortly) describe the cases on which bonding 
tends to make update-storms or better: in which cases does it make a 
reply to the client? AFAIK it only does this, if packets from a 
client are comming on the wrong interface. I tried to analyse the 
problem but I don't find the needle in the hay-stack.
