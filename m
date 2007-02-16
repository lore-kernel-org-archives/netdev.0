From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: [Sk-drivers] sky2 bonding problem, 802.3ad
Date: Fri, 16 Feb 2007 10:28:45 +0100
Message-ID: <873b56tprm.fsf@kruemel.my-eitzenberger.de>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
	<200702152013.l1FKDE22017473@death.nxdomain.ibm.com>
	<877iuitqcw.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:63122 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423471AbXBPJ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 04:28:48 -0500
In-Reply-To: <877iuitqcw.fsf@kruemel.my-eitzenberger.de> (Holger
 Eitzenberger's message of "Fri, 16 Feb 2007 10:15:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger <holger@my-eitzenberger.de> writes:

>  bonding: ad_tx_machine() 1210: Sent LACPDU on port 1
>  bonding: bond_3ad_rx_indication() 2175: Received LACPDU on port 1
>  bonding: ad_rx_machine() 1123: Rx Machine: Port=1, Last State=6, Curr
>    State=6

One important point I forgot about in my previous post: the host
receives LACPDUs, but still the bond does not work.

Also note that the other e1000 bond works happily: it is in fact the
link which I use to configure it currently (via telnet).

  /holger
