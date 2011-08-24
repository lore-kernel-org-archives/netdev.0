From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 68/75] hv: netvsc: convert to SKB paged frag API.
Date: Wed, 24 Aug 2011 22:10:55 +0100
Message-ID: <1314220255.17978.695.camel@dagon.hellion.org.uk>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	 <1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
	 <20110824183010.GG15675@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hank Janssen <hjanssen@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Abhishek Kane <v-abkane@microsoft.com>,
	devel@driverdev.osuosl.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110824183010.GG15675@dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-24 at 14:30 -0400, Konrad Rzeszutek Wilk wrote:
> What is with the 'XXX' ?

Those bits were supposed to be the "net: add support for
per-paged-fragment destructors" patch which I accidentally squashed into
the hv driver.

As I said to Dan they are a reminder referring to the dilemma I
mentioned in the intro mail. Basically that ".p" is ugly because
gl->frags[0].page isn't actually a paged fragment, it's just that this
driver uses skb_frag_t in its internal datastructures.

Ian.
