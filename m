From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rndis_wlan: allow devdbg arguments to be
 type-checked without DEBUG
Date: Tue, 20 Jan 2009 09:06:10 -0800 (PST)
Message-ID: <20090120.090610.163846658.davem@davemloft.net>
References: <1232456838-10025-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david-b@pacbell.net
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754189AbZATRGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 12:06:09 -0500
In-Reply-To: <1232456838-10025-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 20 Jan 2009 13:07:17 +0000

> This patch removes an #ifdef DEBUG directive so devdbg statements can be
> type-checked at compile time.  Type checking itself is introduced by
> another patch in this series.
> 
> This introduces an unused variable warning which disappears with the
> type-checking patch.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

This adds a warning for the non-DEBUG build.  That's the whole reason
the ifdef is there.

Therefore you must do the devdbg() define change and this ifdef
removal in the same commit.
