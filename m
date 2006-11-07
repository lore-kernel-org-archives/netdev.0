From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Tue, 7 Nov 2006 11:18:07 -0800
Message-ID: <20061107111807.0eec316f@freekitty>
References: <20061005224949.456192755@osdl.org>
	<20061005225209.769741968@osdl.org>
	<20061107132506.GS2667@mathom.us>
	<20061107095104.734326cc@freekitty>
	<20061107185830.GT2667@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50828 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750724AbWKGTSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 14:18:09 -0500
To: Michael Stone <mstone@mathom.us>
In-Reply-To: <20061107185830.GT2667@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Nov 2006 13:58:31 -0500
Michael Stone <mstone@mathom.us> wrote:

> On Tue, Nov 07, 2006 at 09:51:04AM -0800, Stephen Hemminger wrote:
> >Which form of bonding link checking are you using. It could be that
> >bonding MII checking is confused.
> 
> I'm not specifying anything, just "ifenslave bond0 eth2 eth3"
> 
> Mike Stone

Do both ports report carrier present?
	ethtool eth2
	ethtool eth3



-- 
Stephen Hemminger <shemminger@osdl.org>
