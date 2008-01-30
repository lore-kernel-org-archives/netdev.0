From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] [2/2] Remove some unnecessary gotos in established_get_first()
Date: Wed, 30 Jan 2008 09:25:12 +0100
Message-ID: <200801300925.12397.oliver@neukum.org>
References: <20080130901.138686634@suse.de> <20080130080110.35B691B416F@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out001.kontent.com ([81.88.40.215]:49189 "EHLO
	smtp-out001.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbYA3IV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:21:26 -0500
In-Reply-To: <20080130080110.35B691B416F@basil.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 30. Januar 2008 09:01:10 schrieb Andi Kleen:
> 
> gcc does not generate different code for return foo vs bar = foo; goto x;
> x: return bar; So convert it all to direct returns for better readability.

Now suppose somebody needs to change locking. He'll have to convert
it back. IMHO a conditional return is worse than "goto clearly_named_label"

	Regards
		Oliver
