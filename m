From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TSO performance wrt 2.614
Date: Fri, 09 Mar 2007 08:18:54 -0800
Message-ID: <45F188EE.5000508@linux-foundation.org>
References: <bb8a0130703082237q2ac1025haf3cd9f590c47aa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anandvelu thulasiram <anand.vt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38531 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767357AbXCIQSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:18:42 -0500
In-Reply-To: <bb8a0130703082237q2ac1025haf3cd9f590c47aa3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

anandvelu thulasiram wrote:
> Hi all,
>               I'm working on TCP segmentation Offload and I'm using
> Linux -2.6.14 kernel for this. I'm getting about a 6x increase in
> sending by turning off TCP segmentation offload. But When I turn on
> the TSO my performance is getting degraded.  But when I switched back
> to Linux
> 2.6.9 kernel I'm getting 16Mbps more when TSO is enabled.
>
> Is there any TSO patch for linux-2.6.14.
>
>
Which hardware and what is the network connection?
It turns out that older versions of TSO were violating internet 
congestion control
and not counting packets properly.
