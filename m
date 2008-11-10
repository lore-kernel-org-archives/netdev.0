From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] dccp: Query supported CCIDs
Date: Mon, 10 Nov 2008 13:16:45 -0800 (PST)
Message-ID: <20081110.131645.149021023.davem@davemloft.net>
References: <1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750739AbYKJVQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:16:45 -0500
In-Reply-To: <1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:13 +0100

> This provides a data structure to record which CCIDs are locally supported
> and three accessor functions:
>  - a test function for internal use which is used to validate CCID requests
>    made by the user;
>  - a copy function so that the list can be used for feature-negotiation;
>  - documented getsockopt() support so that the user can query capabilities.
> 
> The data structure is a table which is filled in at compile-time with the
> list of available CCIDs (which in turn depends on the Kconfig choices).
> 
> Using the copy function for cloning the list of supported CCIDs is useful for
> feature negotiation, since the negotiation is now with the full list of available
> CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation
> will not fail if the peer requests to use CCID3 instead of CCID2.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
