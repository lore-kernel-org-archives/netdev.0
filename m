From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 08 Nov 2006 16:55:18 +0100
Message-ID: <1163001318.3138.346.camel@laptopd505.fenrus.org>
References: <1162924354.10806.172.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@sunset.davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45719 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S965932AbWKHPzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 10:55:23 -0500
To: tim.c.chen@linux.intel.com
In-Reply-To: <1162924354.10806.172.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-07 at 10:32 -0800, Tim Chen wrote:
> The patch
> 
> [TCP]: Send ACKs each 2nd received segment
> commit: 1ef9696c909060ccdae3ade245ca88692b49285b
> http://kernel.org/git/?
> p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ef9696c909060ccdae3ade245ca88692b49285b
> 
> reduced Volanomark benchmark throughput by 10%.  
> This is because Volanomark sends 
> short message (<100 bytes) on its TCP
> connections.  This patch increases the number of ACKs 
> traffic by 3.5 times.  
> 
> By adopting this patch, we assume that with
> small segment, having short delay is important 
> enough that we are willing to reduce bandwidth 
> with more ACKs.  

I wonder if it's an option to use low priority QoS fields for these acks
(heck I don't even know if ACKs have such fields in their packet) so
that they can get dropped if there are more packets then there is
bandwidth ....


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

