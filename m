From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/2][RAW]: Add raw_hashinfo member on struct
 proto.
Date: Sat, 22 Mar 2008 16:56:58 -0700 (PDT)
Message-ID: <20080322.165658.160912948.davem@davemloft.net>
References: <47DFC912.2000106@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755378AbYCVX4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 19:56:45 -0400
In-Reply-To: <47DFC912.2000106@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 18 Mar 2008 16:52:18 +0300

> Sorry for the patch sequence confusion :| but I found that the
> similar thing can be done for raw sockets easily too late.
> 
> Expand the proto.h union with the raw_hashinfo member and use
> it in raw_prot and rawv6_prot. This allows to drop the protocol
> specific versions of hash and unhash callbacks.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
