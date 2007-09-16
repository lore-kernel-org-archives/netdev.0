From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CIPSO: remove duplicated code in the
 cipso_v4_*_getattr() functions
Date: Sat, 15 Sep 2007 21:45:49 -0700 (PDT)
Message-ID: <20070915.214549.26284935.davem@davemloft.net>
References: <20070912192305.18318.11911.stgit@flek.americas.hpqcorp.net>
	<20070912192938.18318.22897.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54315
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750714AbXIPEpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:45:55 -0400
In-Reply-To: <20070912192938.18318.22897.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 12 Sep 2007 15:29:38 -0400

> The bulk of the CIPSO option parsing/processing in the cipso_v4_sock_getattr()
> and cipso_v4_skb_getattr() functions are identical, the only real difference
> being where the functions obtain the CIPSO option itself.  This patch creates
> a new function, cipso_v4_getattr(), which contains the common CIPSO option
> parsing/processing code and modifies the existing functions to call this new
> helper function.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied to net-2.6.24, thanks Paul.
