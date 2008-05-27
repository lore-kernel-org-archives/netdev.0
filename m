From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [DCCP]: Fix to handle short sequence numbers
 packet correctly
Date: Tue, 27 May 2008 06:22:52 -0700 (PDT)
Message-ID: <20080527.062252.108813459.davem@davemloft.net>
References: <dccp_bug_fixes_and_format_updates>
	<1211877167-10995-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org, yjwei@cn.fujitsu.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756848AbYE0NW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:22:56 -0400
In-Reply-To: <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:41 +0100

> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> RFC4340 said:
>   8.5.  Pseudocode
>        ...
>        If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
>              has short sequence numbers), drop packet and return
> 
> But DCCP has some mistake to handle short sequence numbers packet, now
> it drop packet only if P.type is Data, Ack, or DataAck and P.X == 0.
> 
> This patch fixed this problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

As it is a bug fix I've applied this to net-2.6, thanks.
