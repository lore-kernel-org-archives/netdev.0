From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 01/10] cxgb4vf: minor comment/symbolic name cleanup.
Date: Thu, 11 Nov 2010 09:17:07 -0800
Message-ID: <201011110917.07931.leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com> <1289441052-4925-1-git-send-email-leedom@chelsio.com> <1289445578.15905.173.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5560 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab0KKRRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:17:12 -0500
In-Reply-To: <1289445578.15905.173.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[Second attempt: First effort at replying got dropped because of local relay 
security insanity ... and would have been dropped in any case because my mailer 
was configured for HTML "Rich Text. -- Casey]]

| | From: Joe Perches <joe@perches.com>
| | Date: Wednesday, November 10, 2010 07:19 pm
| | 
| | >  		const struct port_info *pi = netdev_priv(dev);
| | >  		int qs, msi;
| | > 
| | > -		for (qs = 0, msi = MSIX_NIQFLINT;
| | > +		for (qs = 0, msi = MSIX_IQFLINT;
| | > 
| | >  		     qs < pi->nqsets;
| | >  		     qs++, msi++) {
| | 
| | This for now fits on a single line.
| | 
| | > -	struct fw_cmd_hdr *cmd_hdr = (struct fw_cmd_hdr *)rpl;
| | > +	const struct fw_cmd_hdr *cmd_hdr = (const struct fw_cmd_hdr *)rpl;
| | > @@ -1265,7 +1265,7 @@ int t4vf_handle_fw_rpl(struct adapter *adapter,
| | > const __be64 *rpl) -		const struct fw_port_cmd *port_cmd = (void *)rpl;
| | > +		const struct fw_port_cmd *port_cmd = (const void *)rpl;
| | 
| | might be better to have a consistent casting style.
| | 1st uses a direct cast, 2nd an implicit one.
| 
|   Sure.  These both look good.  May I fix these in a follow up patch or
|   should I respin the patches with this last change?


[[To which Joe responded to me because of the aforementioned HTML email botch:]]


|  Date: Thu Nov 11 06:55:43 2010
|  From: Joe Perches <joe@perches.com>
|  To: Casey Leedom <leedom@chelsio.com>
|  
| It's just trivial formatting.
| Do what you think appropriate.
| 
| fyi: linux-kernel doesn't accept emails with html formatting.
| You'll need to default to text otherwise your emails to
| any kernel related list will be silently rejected.
| 
| cheers, Joe


Thanks Joe!

Casey
