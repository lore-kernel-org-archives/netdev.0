From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 07/10] net: only allow paged fragments with the same
 destructor to be coalesced.
Date: Wed, 11 Apr 2012 07:45:19 +0000
Message-ID: <1334130319.12209.187.camel@dagon.hellion.org.uk>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-7-git-send-email-ian.campbell@citrix.com>
	 <1334088690.2624.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	"James Morris" <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:34806 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab2DKHpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 03:45:22 -0400
In-Reply-To: <1334088690.2624.1.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 21:11 +0100, Ben Hutchings wrote:
> Shouldn't this be folded into the previous change 'net: add support for
> per-paged-fragment destructors'?  Maybe it doesn't matter since nothing
> is setting a non-NULL fragment destructor yet.

I keep following exactly the same thought pattern and then ending up
leaving it due to indecision. I'll squash it next time unless anyone
thinks it is worth keeping split out.

Ian.
