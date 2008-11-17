From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Date: Sun, 16 Nov 2008 22:50:40 -0800 (PST)
Message-ID: <20081116.225040.197479116.davem@davemloft.net>
References: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
	<1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50660
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751514AbYKQGul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:50:41 -0500
In-Reply-To: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:15 +0100

> This adds a hook to resolve features whose value depends on the choice of
> CCID. It is done at the server since it can only be done after the CCID
> values have been negotiated; i.e. the client will add its CCID preference
> list on the Change options sent in the Request, which will be reconciled
> with the local preference list of the server.
> 
> The concept is documented on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
> 				implementation_notes.html#ccid_dependencies
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.

> +	list_for_each_entry(entry, fn_list, node)
> +		if (entry->feat_num == feat_num && entry->is_local == is_local)
> +			return entry;
> +		else if (entry->feat_num > feat_num)
> +			break;

Personally, I would have put braces around this basic block.
