From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: shape traffic on tun interfaces
Date: Sun, 1 Aug 2010 11:27:12 +0100
Message-ID: <0pufi7-0ii.ln1@chipmunk.wormnet.eu>
References: <301941280614170@web105.yandex.ru>
Cc: lartc@mailman.ds9a.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:59865 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab0HALIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Aug 2010 07:08:18 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OfWOv-0004AG-P6
	for netdev@vger.kernel.org; Sun, 01 Aug 2010 13:08:17 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 01 Aug 2010 13:08:17 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 01 Aug 2010 13:08:17 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Franchoze Eric <franchoze@yandex.ru> wrote:
>
> Do we have any interface to shape traffic per destination IP? The 
> standrad HTB shapes it per device, which is not suitable for case if 
> limitation required per destination IP. For example openvpn server 
> which servers about 3000 clients and has 10 internal tun interfases 
> (tun0-tun9). 
>
Do the QoS on your next hop router or on the interface all your 
de-encapsulated VPN traffic flows over (ie. 'eth0') instead.

Cheers

-- 
Alexander Clouter
.sigmonster says: He who always plows a straight furrow is in a rut.

