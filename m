From: andrei radulescu-banu <iubica2@yahoo.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 10:46:52 -0700 (PDT)
Message-ID: <544527.16391.qm@web56614.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web56614.mail.re3.yahoo.com ([66.196.97.58]:34740 "HELO
	web56614.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754667AbXGSRqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 13:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> [Andrei] VLAN_TX_SKB_CB() is perfect for that.
> [Patrick, Stephen] No its not. Its only legal to use while something has ownership
of the skb. Between VLAN devices and real devices qdiscs are
free to use it.

All right, using VLAN_TX_SKB_CB() is a bad idea. In that case, we need to amend the skb struct, I don't see another way.





       
____________________________________________________________________________________
Be a better Globetrotter. Get better travel answers from someone who knows. Yahoo! Answers - Check it out.
http://answers.yahoo.com/dir/?link=list&sid=396545469
