From: Glen Gray <glen.gray@lincor.com>
Subject: Status of r8169 and Multicast
Date: Wed, 27 Feb 2008 09:10:29 +0000
Message-ID: <1985987B-FA5B-4885-B667-AB3A9C722FBD@lincor.com>
References: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com> <20080226201441.GA15796@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:1512 "EHLO
	scmp07.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753309AbYB0JXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 04:23:19 -0500
In-Reply-To: <20080226201441.GA15796@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Francois,

It's been a while since I've been in touch and it's been a while since  
I've been involved in the project at work that deals with these Set  
top boxes with the Realtek chipset

If you recall, we had problems with kernels correctly accessing  
multicast broadcasts of our IPTV service (SAP announcements). You sent  
me a patch at one point but I never got around to testing it. To get  
around it we went with the Realtek driver which didn't seem to have  
the problem but which did have some freezing problems. You kindly  
provided a patch for this which seemed to resolve the problem.  
However, we've recently been made aware that there are still issues  
with freezing, especially during channel changes (subscribing to a new  
multicast address).

I'm going to be looking into this shortly, but I was wondering if the  
current stable or development branches are known to have the previous  
multicast issues fixed ? From memory the device would come up as only  
supporting igmpv3 when we needed it to do igmpv2, I think this was why  
it couldn't pick up the SAP announcements.

Kind Regards,
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682
