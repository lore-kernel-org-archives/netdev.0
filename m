From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 07/10] net: only allow paged fragments with the same
 destructor to be coalesced.
Date: Tue, 10 Apr 2012 21:11:30 +0100
Message-ID: <1334088690.2624.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-7-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37231 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755426Ab2DJULi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 16:11:38 -0400
In-Reply-To: <1334067984-7706-7-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shouldn't this be folded into the previous change 'net: add support for
per-paged-fragment destructors'?  Maybe it doesn't matter since nothing
is setting a non-NULL fragment destructor yet.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
