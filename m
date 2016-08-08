From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: vxlan: lwt: Use source ip address during
 route lookup.
Date: Mon, 08 Aug 2016 14:16:42 -0700 (PDT)
Message-ID: <20160808.141642.989376017859611764.davem@davemloft.net>
References: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36778 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcHHVQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:16:48 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so24577614pab.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:16:48 -0700 (PDT)
In-Reply-To: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri,  5 Aug 2016 17:45:36 -0700

> LWT user can specify destination as well as source ip address
> for given tunnel endpoint. But vxlan is ignoring given source
> ip address. Following patch uses both ip address to route the
> tunnel packet. This consistent with other LWT implementations,
> like GENEVE and GRE.
> 
> Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
