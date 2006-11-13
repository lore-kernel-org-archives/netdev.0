From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [2.6 patch] the scheduled removal of the frame diverter
Date: Mon, 13 Nov 2006 18:14:10 -0500
Message-ID: <8FCCCD3C-FA3D-4857-B76D-56087D1519A0@mac.com>
References: <20061113210425.GI22565@stusta.de>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.183]:61393 "EHLO smtpout.mac.com")
	by vger.kernel.org with ESMTP id S933156AbWKMXOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 18:14:25 -0500
In-Reply-To: <20061113210425.GI22565@stusta.de>
To: Adrian Bunk <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 13, 2006, at 16:04:25, Adrian Bunk wrote:
> This patch contains the scheduled removal of the frame diverter.
>
> [snip]
>
> -config NET_DIVERT
> -	bool "Frame Diverter (EXPERIMENTAL)"
> -	depends on EXPERIMENTAL && BROKEN
> -	---help---
> -	  The Frame Diverter allows you to divert packets from the
> -	  network, that are not aimed at the interface receiving it (in
> -	  promisc. mode). Typically, a Linux box setup as an Ethernet bridge
> -	  with the Frames Diverter on, can do some *really* transparent www
> -	  caching using a Squid proxy for example.

 From my understanding of iptables/ebtables, identical functionality  
is already avaialble within that framework; and as such this patch is  
just removing broken experimental and redundant code.  The IPTables  
code also properly handles IPv6 and all the other old warts of the  
frame diverter as well.  I agree that this should go.

Cheers,
Kyle Moffett
