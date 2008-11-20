From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Date: Thu, 20 Nov 2008 01:03:21 -0800 (PST)
Message-ID: <20081120.010321.191266507.davem@davemloft.net>
References: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<20081116.225040.197479116.davem@davemloft.net>
	<20081118050346.GA3846@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbYKTJDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:03:21 -0500
In-Reply-To: <20081118050346.GA3846@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Nov 2008 06:03:47 +0100

> | > +	list_for_each_entry(entry, fn_list, node)
> | > +		if (entry->feat_num == feat_num && entry->is_local == is_local)
> | > +			return entry;
> | > +		else if (entry->feat_num > feat_num)
> | > +			break;
> | 
> | Personally, I would have put braces around this basic block.
> | 
> If it is possible to modify without disturbance, I attach a patch for this and
> have changed it in the test tree.
> 
> I have checked that making this change does not affect subsequent
> patches - it works with either variant.

Applied, thanks Gerrit.  Please give a signoff next time.
