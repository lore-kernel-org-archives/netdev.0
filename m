From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: fix return values in enic_set_coalesce
Date: Mon, 07 Jul 2014 21:34:02 -0700 (PDT)
Message-ID: <20140707.213402.533534622692381995.davem@davemloft.net>
References: <1404295935-13597-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com,
	ben@decadent.org.uk
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaGHEeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:34:03 -0400
In-Reply-To: <1404295935-13597-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed,  2 Jul 2014 15:42:15 +0530

> enic_set_coalesce() has two problems.
> 
> * It should return -EINVAL and not -EOPNOTSUPP for invalid coalesce values.
> 
> * In case of MSIX, enic_set_coalesce return error after applying requested
>   coalescing setting partially. We should either apply all the setting requeste
>   and return success or apply non and return error.
> 
> * This patch also simplifies the algo.
> 
> This was introduced by
> '7c2ce6e60f703 enic: Add support for adaptive interrupt coalescing'
> 
> These changes were suggested by Ben Hutchings here
> http://www.spinics.net/lists/netdev/msg283972.html
> 
> Also change enic driver version.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks.
