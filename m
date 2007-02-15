From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 23:27:20 +0100
Message-ID: <87bqjvt5tj.fsf@kruemel.my-eitzenberger.de>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
	<20070215213135.GC30353@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59000 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161510AbXBOW1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 17:27:47 -0500
In-Reply-To: <20070215213135.GC30353@gospo.rdu.redhat.com> (Andy
 Gospodarek's message of "Thu, 15 Feb 2007 16:31:36 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> writes:

> I get the impression that sky2 has never worked for you.  Is that
> correct?  There was an skge problem I noticed a while ago where on reset
> the multicast membership list was cleared.  

Well, when it comes to bonding: yes, almost :).  When I noticed the fact
that IFF_NOARP was set on the other interface I experimented a bit with
these flags, ala

  ip l set dev eth0 arp on|off

and I 2-3 times had a link.

  /holger
