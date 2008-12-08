From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] dccp: Integration of dynamic feature activation -
 part 2 (server side)
Date: Mon, 08 Dec 2008 01:16:04 -0800 (PST)
Message-ID: <20081208.011604.20334616.davem@davemloft.net>
References: <1228581657-6724-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751368AbYLHJQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:16:03 -0500
In-Reply-To: <1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:52 +0100

> This patch integrates the activation of features at the end of negotiation
> into the server-side code.
> 
> Note regarding the removal of 'const':
> --------------------------------------
>  The 'const' attribute has been removed from 'dreq' since dccp_activate_values()
>  needs to operate on dreq's feature list. Part of the activation is to remove
>  those options from the list that have already been confirmed, hence it is not
>  purely read-only.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
