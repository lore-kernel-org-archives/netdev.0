From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 09:43:24 -0700
Message-ID: <20060523094324.11926fcc@localhost.localdomain>
References: <44731733.7000204@ti-wmc.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3787 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932081AbWEWQn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 12:43:28 -0400
To: Herman Elfrink <herman.elfrink@ti-wmc.nl>
In-Reply-To: <44731733.7000204@ti-wmc.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 May 2006 16:07:47 +0200
Herman Elfrink <herman.elfrink@ti-wmc.nl> wrote:

>  
> FLAME stands for "Forwarding Layer for Meshing"
> 
> FLAME provides an intermediate layer between the network layer (e.g. 
> IPv4/IPv6) and the link (MAC) layer, providing L2.5 meshing. Both 
> network layer and MAC layer can be used unchanged: to the network layer 
> FLAME appears as a normal Ethernet-type MAC layer, and the underlying 
> `real' MAC layer will see it as just another type of network layer.
> 

Didn't you just reinvent 802.1d bridging? and/or WDS?

As far as the Ethernet protocol field. Getting a real assigned number
would have to come out of the IEEE 802. 

You would need
	http://standards.ieee.org/regauth/ethertype/forms/index.html

It is cheaper (free vs $2500) to get a LLC sap assigned, but then
you would have to change the protocol.
	http://standards.ieee.org/regauth/llc/index.html
