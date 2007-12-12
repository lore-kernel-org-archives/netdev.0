From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Wed, 12 Dec 2007 09:12:05 +0900
Message-ID: <b25c3fa70712111612o16a62b49g6709aa728f31e27a@mail.gmail.com>
References: <001801c83bd6$2001d410$9c94fea9@jason>
	 <20071211.023218.31965443.davem@davemloft.net>
	 <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:44359 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbXLLAMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 19:12:05 -0500
Received: by rv-out-0910.google.com with SMTP id k20so14150rvb.1
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 16:12:05 -0800 (PST)
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/12, Brandeburg, Jesse <jesse.brandeburg@intel.com>:
>
> all drivers using NAPI in 2.6.24+ (NNAPI??) must return zero here, after
> calling netif_rx_complete.  netif_rx_complete plus work_done != 0 causes
> a bug.
>

Brandeburg,
Don't we need to return non-zero work_done after netif_rx_complete if
work_done != weight?

Thanks,
Joonwoo
