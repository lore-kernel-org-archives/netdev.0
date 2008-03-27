From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [NETFILTER]: Replate direct proc_fops assignment
 with proc_create call.
Date: Thu, 27 Mar 2008 16:56:22 -0700 (PDT)
Message-ID: <20080327.165622.62269086.davem@davemloft.net>
References: <1206602453-11321-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752623AbYC0X4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 19:56:22 -0400
In-Reply-To: <1206602453-11321-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 27 Mar 2008 10:20:53 +0300

> This elliminates infamous race during module loading when one could lookup
> proc entry without proc_fops assigned.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Patrick, this is a pretty straightforward transformation
and bug fix, so I have applied this directly to net-2.6

Thanks Denis.
