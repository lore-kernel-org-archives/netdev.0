From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] Move the get_net() from sock_copy()
Date: Thu, 01 Nov 2007 00:32:37 -0700 (PDT)
Message-ID: <20071101.003237.22157310.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<472886C8.5010601@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753075AbXKAHcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:32:39 -0400
In-Reply-To: <472886C8.5010601@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:44:40 +0300

> The sock_copy() is supposed to just clone the socket. In a perfect
> world it has to be just memcpy, but we have to handle the security
> mark correctly. All the extra setup must be performed in sk_clone() 
> call, so move the get_net() into more proper place.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
