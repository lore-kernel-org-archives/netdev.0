From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] SCTP: Enable the sending of the AUTH chunk.
Date: Sun, 16 Sep 2007 19:32:59 -0700 (PDT)
Message-ID: <20070916.193259.124266256.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897955001857-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751071AbXIQCdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:33:00 -0400
In-Reply-To: <11897955001857-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:56 -0400

> SCTP-AUTH, Section 6.2:
> 
>    Endpoints MUST send all requested chunks authenticated where this has
>    been requested by the peer.  The other chunks MAY be sent
>    authenticated or not.  If endpoint pair shared keys are used, one of
>    them MUST be selected for authentication.
> 
>    To send chunks in an authenticated way, the sender MUST include these
>    chunks after an AUTH chunk.  This means that a sender MUST bundle
>    chunks in order to authenticate them.
> 
>    If the endpoint has no endpoint pair shared key for the peer, it MUST
>    use Shared Key Identifier 0 with an empty endpoint pair shared key.
>    If there are multiple endpoint shared keys the sender selects one and
>    uses the corresponding Shared Key Identifier
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks.
