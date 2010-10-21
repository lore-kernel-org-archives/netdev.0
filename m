From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert c6537d6742985da1fbf12ae26cde6a096fd35b5c
Date: Thu, 21 Oct 2010 04:11:30 -0700 (PDT)
Message-ID: <20101021.041130.98891966.davem@davemloft.net>
References: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
	<1287659176-14504-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, luca@llucax.com.ar
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756860Ab0JULLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:11:08 -0400
In-Reply-To: <1287659176-14504-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nhorman@tuxdriver.com
Date: Thu, 21 Oct 2010 07:06:15 -0400

> From: Neil Horman <nhorman@tuxdriver.com>
> 
> Backout the tipc changes to the flags int he subscription message.  These
> changees, while reasonable on the surface, interefere with user space ABI
> compatibility which is a no-no.  This was part of the changes to fix the
> endianess issues in the TIPC protocol, which would be really nice to do but we
> need to do so in a way that is backwards compatible with user space.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable.
