From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v2] ieee802154: properly
 unshare skbs in ieee802154 *_rcv functions
Date: Mon, 17 Mar 2014 19:02:32 +0100
Message-ID: <20140317180229.GA12756@omega>
References: <1395077419-20456-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:64360 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533AbaCQSCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 14:02:39 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so4403632eek.8
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 11:02:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1395077419-20456-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 06:30:19PM +0100, Phoebe Buckheister wrote:
> ieee802154 sockets do not properly unshare received skbs, which leads to
> panics (at least) when they are used in conjunction with 6lowpan, so
> run skb_share_check on received skbs.
> 6lowpan also contains a use-after-free, which is trivially fixed by
> replacing the inlined skb_share_check with the explicit call.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>

Tested-by: Alexander Aring <alex.aring@gmail.com>
