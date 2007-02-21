From: David Miller <davem@davemloft.net>
Subject: Re: [AF_PACKET] remove unnecessary casts
Date: Tue, 20 Feb 2007 23:20:07 -0800 (PST)
Message-ID: <20070220.232007.78707822.davem@davemloft.net>
References: <20070214233558.GA3819@avocado.homenet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lunz@falooley.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34214
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932835AbXBUHUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:20:09 -0500
In-Reply-To: <20070214233558.GA3819@avocado.homenet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Lunz <lunz@falooley.org>
Date: Wed, 14 Feb 2007 18:35:58 -0500

> packet_lookup_frame() always returns tpacket_hdr*, so there's no reason
> to return char* and require casting by callers.
> 
> Also, remove a cast of void*.
> 
> Signed-off-by: Jason Lunz <lunz@falooley.org>

Applied, thank you.
