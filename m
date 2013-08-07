From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Wed, 07 Aug 2013 13:23:25 -0700
Message-ID: <1375907005.4004.47.camel@edumazet-glaptop>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
	 <5200A8BC.4010402@linux.intel.com>
	 <20130806180806.GA8993@sbohrermbp13-local.rgmadvisors.com>
	 <52013F9A.9020005@linux.intel.com>
	 <1375905901.27403.22.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:35336 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343Ab3HGUX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 16:23:26 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so2299205pbb.38
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 13:23:26 -0700 (PDT)
In-Reply-To: <1375905901.27403.22.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 22:05 +0200, Ben Hutchings wrote:

> It seems like sk_mark_napi_id() should only be called on connected
> sockets for now.

I concur.
