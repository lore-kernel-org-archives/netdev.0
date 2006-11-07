From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Tue, 7 Nov 2006 09:51:04 -0800
Message-ID: <20061107095104.734326cc@freekitty>
References: <20061005224949.456192755@osdl.org>
	<20061005225209.769741968@osdl.org>
	<20061107132506.GS2667@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9681 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932712AbWKGRvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 12:51:09 -0500
To: Michael Stone <mstone@mathom.us>
In-Reply-To: <20061107132506.GS2667@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Nov 2006 08:25:07 -0500
Michael Stone <mstone@mathom.us> wrote:

> The skge 1.9 patch is looking good on older syskonnect fiber cards.  
> Stability issues seem to be taken care of and performance is good. There 
> are some strange interactions with bonding, however. If I try to put 
> both interfaces of an sk-9844 into a bonded interface, I only see 
> traffic from one of them. If I try to config the bonded interface down, 
> the system hangs. If I tcpdump either of the individual interfaces 
> (before bonding them) I see all the expected traffic.
> 
> Mike Stone

Which form of bonding link checking are you using. It could be that
bonding MII checking is confused.

-- 
Stephen Hemminger <shemminger@osdl.org>
