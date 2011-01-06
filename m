From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: Use ioctl() to list all network interfaces.
Date: Thu, 6 Jan 2011 17:07:16 +0000
Message-ID: <4f9hv7-kev.ln1@chipmunk.wormnet.eu>
References: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:54624 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753633Ab1AFRIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 12:08:21 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PatK0-0000bv-BU
	for netdev@vger.kernel.org; Thu, 06 Jan 2011 18:08:20 +0100
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 18:08:20 +0100
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 18:08:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chin Shi Hong <cshong87@gmail.com> wrote:
>
> The following codes are just part of my application's source codes:
> 
> --begin of some codes--
> ifconf ifc;
> ret = ioctl(n, SIOCGIFCONF,&ifc);
> --End of some codes--
> 
> My application's role is to display all network interfaces, including
> the network interface which are down.
> 
> However, with the above codes, my application only display the network
> interface which are already up. The network interface which are down
> will not be displayed.
> 
> So, what can I do to make my application display all network
> interfaces, including the network interface which are down?
>
getifaddrs(), you get the IPv6 ones too this way.

Cheers

-- 
Alexander Clouter
.sigmonster says: I've only got 12 cards.

