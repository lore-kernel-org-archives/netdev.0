From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Fri, 9 Jul 2010 15:50:13 +0900
Message-ID: <20100709065012.GB24576@verge.net.au>
References: <1278578095-25324-2-git-send-email-karl@hiramoto.org>
 <20100708.214745.48520104.davem@davemloft.net>
 <4C36C353.9080501@hiramoto.org>
 <20100708.233801.258129125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: karl@hiramoto.org, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57856 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab0GIGuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:50:17 -0400
Content-Disposition: inline
In-Reply-To: <20100708.233801.258129125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 08, 2010 at 11:38:01PM -0700, David Miller wrote:
> From: Karl Hiramoto <karl@hiramoto.org>
> Date: Fri, 09 Jul 2010 08:36:03 +0200
> 
> > Ok, fixing it,  but there are 100's of occurences in net/ like i had it. :-)
> 
> I would be happy to see a patch which fixes them up :-)

Really? By my calculations it would be an awful lot of churn.

$ find net/ -type f -name "*.[chS]" | xargs grep "\/\* *$" | wc -l
6833
$ find net/ -type f -name "*.[chS]" | xargs grep -l "\/\* *$" | wc -l
929


