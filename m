From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: consistent disable_xfrm behaviour
Date: Mon, 04 Dec 2006 16:20:33 +0100
Message-ID: <45743CC1.1080904@trash.net>
References: <457437EA.7000406@trash.net> <XMMS.LNX.4.64.0612041005260.4314@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47085 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936996AbWLDPR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:17:28 -0500
To: James Morris <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0612041005260.4314@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 4 Dec 2006, Patrick McHardy wrote:
> 
> 
>>disable_xfrm - BOOLEAN
>>
>>        Disable IPSEC encryption on this interface, whatever the policy
>>
>>Opinions?
> 
> 
> Looks good to me, wonder what the original rationale was, though.

Me too. It was introduced by this patch:

http://linux.bkbits.net:8080/linux-2.6/cset@3dcb777f4YjzKm-lG0COu5u-oTLEWA?nav=index.html|src/|src/net|src/net/ipv4|related/net/ipv4/route.c

which only mentions the loopback device, in which case it
doesn't matter.

Alexey, do you remember what the original intent of this was?

