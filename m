From: Christian Samsel <csamsel@gmxpro.de>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Fri, 18 Dec 2009 18:56:59 +0100
Message-ID: <200912181856.59901.csamsel@gmxpro.de>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
 <20091218093240.64ca7d88@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:47046 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbZLRR5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:57:07 -0500
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUV00ESA0J6PSC0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 18 Dec 2009 18:57:06 +0100 (CET)
Received: from oxygen-mobile.localnet ([unknown] [80.135.53.190])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0KUV009E10IY6O10@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Fri, 18 Dec 2009 18:57:06 +0100 (CET)
In-reply-to: <20091218093240.64ca7d88@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 18. Dezember 2009 18:32:40 schrieb Stephen Hemminger:
> On Fri, 18 Dec 2009 14:18:37 +0100
> 
> Christian Samsel <christian.samsel@rwth-aachen.de> wrote:
> > This patch adds a new feature to netem: The newly introduced parameter
> > reorderdelay TIME is the time a reordered packet is delayed. It can be
> > used in a combination with delay TIME to enable netem to produce late
> > packets, which is not possible in the standard netem / iproute2. In the
> > standard version reordered packets are always sent immediately and
> > therefore are always early packets.
> 
> I like the idea but is it binary compatible with older kernels/ older
>  iproute2 utilities?
> 
Thats a good point. I will test it. So far i think it should work.
