From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [CCID-2/3]: Fix sparse warnings
Date: Tue, 27 May 2008 06:37:14 -0700 (PDT)
Message-ID: <20080527.063714.19615390.davem@davemloft.net>
References: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-6-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757277AbYE0NhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:37:18 -0400
In-Reply-To: <1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:46 +0100

> This patch fixes the following two sparse warnings:
> 
>  1. Due to a nested min(max()) expression, sparse gave the following warnings:
> 
>     net/dccp/ccids/ccid3.c:91:21: warning: symbol '__x' shadows an earlier one
>     net/dccp/ccids/ccid3.c:91:21: warning: symbol '__y' shadows an earlier one
> 
>     (Didn't use clamp() here since this part is liketly to be split later, when
>      implementing the changes from draft rfc3448bis.)
> 
>  2. Declaration of function prototypes was in .c instead of .h file.
>     This resulted in "should it be static" warnings. Corrected by moving the
>     declarations to the tfrc.h file instead of the tfrc.c file.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Conflicts with hctx prefix changes, please respin.
