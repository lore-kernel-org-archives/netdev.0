From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bridge: vlan: enforce no pvid flag in vlan
 ranges
Date: Sun, 11 Oct 2015 16:13:26 +0200
Message-ID: <20151011141326.GA2080@nanopsycho>
References: <20151011071208.GA2188@nanopsycho.orion>
 <1444560596-7140-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	eladr@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37281 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbJKONa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 10:13:30 -0400
Received: by wijq8 with SMTP id q8so24262327wij.0
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 07:13:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444560596-7140-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 11, 2015 at 12:49:56PM CEST, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>Currently it's possible for someone to send a vlan range to the kernel
>with the pvid flag set which will result in the pvid bouncing from a
>vlan to vlan and isn't correct, it also introduces problems for hardware
>where it doesn't make sense having more than 1 pvid. iproute2 already
>enforces this, so let's enforce it on kernel-side as well.
>
>Reported-by: Elad Raz <eladr@mellanox.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
