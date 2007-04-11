From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-2.6.22 plans...
Date: Wed, 11 Apr 2007 11:57:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704111129180.28337@kivilampi-30.cs.helsinki.fi>
References: <20070410.135746.106438579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50523 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbXDKI5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 04:57:16 -0400
In-Reply-To: <20070410.135746.106438579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007, David Miller wrote:

> As the merge window approaches I've made a decision about how to
> handle the TCP RB-Tree work since it's getting really close.
> 
> First, I'm going to rebase the net-2.6.22 tree after making a quick
> run through my patch backlog looking for low hanging fruit.  I will
> include the TCP write queue abstraction bits but not any of the
> TCP RB-Tree based work.

I've two FRTO related patches dealing with application limited cases done 
and tested which could go to 2.6.22. I suspect that they do not conflict 
with anything even if you're doing some tree base manipulation since the 
abstraction bits remain. I'll try to arrange them for submission today and 
you can consider them at the time that suits you best (or even leave 
them to 2.6.23 if you seem to run out of time)... 

Rest can wait till 2.6.23 I think.


-- 
 i.
