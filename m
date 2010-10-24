From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: clean up handling of local/transient counter
 vars
Date: Sun, 24 Oct 2010 15:23:50 -0700 (PDT)
Message-ID: <20101024.152350.260093579.davem@davemloft.net>
References: <1287440084-4848-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933104Ab0JXWX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:23:27 -0400
In-Reply-To: <1287440084-4848-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 18 Oct 2010 18:14:44 -0400

> The temporary variable "i" is needlessly initialized to zero
> in two distinct cases in this file:
> 
> 1) where it is set to zero and then used as an argument in an addition
> before being assigned a non-zero value.
> 
> 2) where it is only used in a standard/typical loop counter
> 
> For (1), simply delete assignment to zero and usages while still
> zero; for (2) simply make the loop start at zero as per standard
> practice as seen everywhere else in the same file.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
