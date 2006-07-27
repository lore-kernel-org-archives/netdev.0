From: Andy Gay <andy@andynet.net>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 10:53:08 -0400
Message-ID: <1154011988.16424.13.camel@tahini.andynet.net>
References: <BAY103-F29E50C26FA020FFF3019DAB2580@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:50578 "EHLO
	vms046pub.verizon.net") by vger.kernel.org with ESMTP
	id S1751541AbWG0OxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 10:53:12 -0400
Received: from andyhp.tranquilitynj.net ([70.18.168.191])
 by vms046.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J3200KL6HCM4ECB@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 27 Jul 2006 09:53:10 -0500 (CDT)
In-reply-to: <BAY103-F29E50C26FA020FFF3019DAB2580@phx.gbl>
To: Marco Berizzi <pupilla@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-27 at 16:36 +0200, Marco Berizzi wrote:
> Andy Gay wrote:
> 
> >It's a function of the IPsec SADB.
(That should have beed SPDB, of course... :)

>  The passthrough conn added a more
> >specific policy that will match before the tunnel policy.
> >You can run 'ip xfrm p' and 'ip xfrm s' to view the policies & state
> >info.
> 
> I did, but no results:
> 
> ip x p | grep '172.16.1.253'
> 
> nor
> 
> ip x s | grep '172.16.1.253'
> 
As Herbert said, the right= address doesn't matter. Search for 10.180.

BTW - in your erlier mail you had "rightsubnet=10.180.0./16". Looks like
a typo there.



