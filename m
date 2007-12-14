From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Fri, 14 Dec 2007 11:06:29 +0900
Message-ID: <b25c3fa70712131806i6520057bt2dadbb4a06d9cf57@mail.gmail.com>
References: <47601A73.5010804@myri.com>
	 <20071212.093819.205755031.davem@davemloft.net>
	 <47602B77.2090202@intel.com>
	 <b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>
	 <47613E22.6060705@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: "Andrew Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:61900 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934338AbXLNCGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 21:06:30 -0500
Received: by rv-out-0910.google.com with SMTP id k20so761480rvb.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 18:06:30 -0800 (PST)
In-Reply-To: <47613E22.6060705@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/13, Andrew Gallatin <gallatin@myri.com>:
>
> If the netif_running() check is indeed required to make a device break
> out of napi polling and respond to an ifconfig down, then I think the
> netif_running() check should be moved up into net_rx_action() to avoid
> potential for driver complexity and bugs like the ones you found.
>
> Drew
>

Yep, It looks good.

Joonwoo
