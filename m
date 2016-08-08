From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: vxlan: lwt: Fix vxlan local traffic.
Date: Mon, 08 Aug 2016 14:16:51 -0700 (PDT)
Message-ID: <20160808.141651.536698027016522691.davem@davemloft.net>
References: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
	<1470444337-3725-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33654 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbcHHVQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:16:53 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so6053040pac.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:16:53 -0700 (PDT)
In-Reply-To: <1470444337-3725-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri,  5 Aug 2016 17:45:37 -0700

> vxlan driver has bypass for local vxlan traffic, but that
> depends on information about all VNIs on local system in
> vxlan driver. This is not available in case of LWT.
> Therefore following patch disable encap bypass for LWT
> vxlan traffic.
> 
> Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
> Reported-by: Jakub Libosvar <jlibosva@redhat.com>
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
