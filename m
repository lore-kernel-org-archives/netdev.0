From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/2][SOCK]: Add udp_hash member to struct
 proto.
Date: Sat, 22 Mar 2008 16:55:59 -0700 (PDT)
Message-ID: <20080322.165559.236374100.davem@davemloft.net>
References: <47DFAC44.9020704@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754272AbYCVXzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 19:55:43 -0400
In-Reply-To: <47DFAC44.9020704@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 18 Mar 2008 14:49:24 +0300

> Inspired by the commit ab1e0a13 ([SOCK] proto: Add hashinfo member to 
> struct proto) from Arnaldo, I made similar thing for UDP/-Lite IPv4 
> and -v6 protocols.
> 
> The result is not that exciting, but it removes some levels of
> indirection in udpxxx_get_port and saves some space in code and text.
> 
> The first step is to union existing hashinfo and new udp_hash on the
> struct proto and give a name to this union, since future initialization 
> of tcpxxx_prot, dccp_vx_protinfo and udpxxx_protinfo will cause gcc 
> warning about inability to initialize anonymous member this way.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
