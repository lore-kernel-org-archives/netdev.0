From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 10:46:03 -0700
Message-ID: <1458323163.26915.8.camel@perches.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
	 <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com>
	 <1458322179.26915.2.camel@perches.com> <56EC3DA6.2090105@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Luis de Bethencourt <luisbg@osg.samsung.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56EC3DA6.2090105@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-03-18 at 17:40 +0000, Luis de Bethencourt wrote:
> On 18/03/16 17:29, Joe Perches wrote:
> > On Fri, 2016-03-18 at 16:35 +0000, Luis de Bethencourt wrote:
> > > Fix order of mac80211_rx_flags description to match the enum.
[]
> > > I want ahead and fixed the order of the descriptions. checkpatch.=
pl was giving
> > > a warning to my previous patch and I had a hunch it was because t=
he wrong order
> > > breaks the parser. Indeed it does and with this patch below check=
patch.pl does
> > > not complain about this flag descriptions anymore.
> > checkpatch complains?=A0=A0About what?
> warning: Enum value 'RX_FLAG_DUP_VALIDATED' not described in enum 'ma=
c80211_rx_flags'

That's not a checkpatch warning.

cheers, Joe
