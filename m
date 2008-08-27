From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sctp: fix random memory dereference with
 SCTP_HMAC_IDENT option.
Date: Wed, 27 Aug 2008 16:10:18 -0700 (PDT)
Message-ID: <20080827.161018.193134500.davem@davemloft.net>
References: <48B42ECA.7010800@redhat.com>
	<12198674171396-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eteo@redhat.com, netdev@vger.kernel.org, security@kernel.org,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753924AbYH0XKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:10:23 -0400
In-Reply-To: <12198674171396-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 27 Aug 2008 16:03:35 -0400

> The number of identifiers needs to be checked against the option
> length.  Also, the identifier index provided needs to be verified
> to make sure that it doesn't exceed the bounds of the array.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied and queued to -stable, thanks Vlad.
