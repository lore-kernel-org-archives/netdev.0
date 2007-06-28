From: Chris Snook <csnook@redhat.com>
Subject: Re: a maze of twisty stats, most different
Date: Thu, 28 Jun 2007 08:47:56 -0400
Message-ID: <4683ADFC.4020000@redhat.com>
References: <46829C48.6080005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763517AbXF1Mr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 08:47:59 -0400
In-Reply-To: <46829C48.6080005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> It seems that every driver, when providing support for ethtool -S 
> functionality, has considerable lattitude when it comes to the stats 
> provided.  Clearly this is very nice for the driver writer(s) as it 
> allows them to provide whatever stats they feel are most "natural" for 
> their NIC(s) and name them as they see fit.

This is deliberate.  Ethtool operates at a very primitive level, and generally 
does little or no translation between the hardware registers and userspace.

> However :)
> 
>  From the standpoint of someone looking from the outside, say someone 
> wanting to consume ethtool -S statistics, it seems to be a big jumble.
> 
> Might there be a way to bring those two camps together?  Is there 
> already, with the same wide availabilty of ethtool, and I've just not 
> seen it?

ifconfig comes to mind, for one.  What statistics are you looking for exactly?

	-- Chris
