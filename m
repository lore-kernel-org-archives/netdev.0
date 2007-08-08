From: David Miller <davem@davemloft.net>
Subject: Re: IPV6_PKTINFO socket option
Date: Wed, 08 Aug 2007 15:02:48 -0700 (PDT)
Message-ID: <20070808.150248.124083797.davem@davemloft.net>
References: <200708081216.51283@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753480AbXHHWCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 18:02:48 -0400
In-Reply-To: <200708081216.51283@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 8 Aug 2007 12:16:51 +0100

>  2. On sparc64 with the same kernel IPV6_PKTINFO works without problems, even pulls
>     out the cmsg fields correctly. Conversely, when trying to set the IPV6_RECVPKTINFO
>     sticky option on the socket, no cmsg fields are generated. 
>     The kernel is of the same date and revision as the i386 kernel - library issue ???
>     It is very annoying, since the application needs to run on both architectures.

Almost certainly a compat layer bug in the kernel, it would
affect 32-bit applications on powerpc64 and similar if so.
