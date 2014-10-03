From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2 -next] cxgb4: clean up a type issue
Date: Fri, 03 Oct 2014 15:46:29 -0700 (PDT)
Message-ID: <20141003.154629.555967384624529643.davem@davemloft.net>
References: <20141002112219.GA25606@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968AbaJCWo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:44:26 -0400
In-Reply-To: <20141002112219.GA25606@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 2 Oct 2014 14:22:19 +0300

> The tx_desc struct hold 8 __be64 values.  The original code took a
> tx_desc pointer then casted it to an int pointer and then casted it to a
> u64 pointer.  It was confusing and triggered some static checker
> warnings.
> 
> I have changed the cxgb_pio_copy() to only take tx_desc pointers.  This
> isn't really a loss of flexibility because anything else was buggy to
> begin with.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Please address the feedback you've received, resubmit this series, and actually
number this second change "2/2" instead of "1/2" :-)

Thanks!
