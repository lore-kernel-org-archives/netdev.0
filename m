From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 14:53:11 -0400
Message-ID: <4D9CB697.3050209@hp.com>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com> <1302113253.3209.126.camel@edumazet-laptop> <20110406183913.GB6825@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8345 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab1DFTEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:04:13 -0400
In-Reply-To: <20110406183913.GB6825@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2011 02:39 PM, Neil Horman wrote: 
> Also, do we have a macro already to see if an ipv6 address is all zeros?  I'm
> not finding one, but I'd hate to re-invent the wheel if I'm just missing it.

ipv6_addr_any() inline in ipv6.h

-Brian
