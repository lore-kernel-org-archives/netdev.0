From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 16:42:31 -0700 (PDT)
Message-ID: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
References: <1316475390.2184.8.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	Alexander H Duyck <alexander.h.duyck@intel.com>
To: jeffrey t kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45169 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab1ISXmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 19:42:31 -0400
In-Reply-To: <1316475390.2184.8.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to see a general solution to allow configuring
napi weight. The Rx weight isn't easily configurable either.
Probably needs to be through ethtool callback since actual value range
and dev -> napi relationship is device specific.
