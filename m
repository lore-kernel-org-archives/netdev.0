From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] macvlan: add tap device backend
Date: Mon, 14 Dec 2009 13:00:36 +0100
Message-ID: <200912141300.37063.arnd@arndb.de>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de> <1259862720-28432-3-git-send-email-arnd@arndb.de> <20091212084112.GA8948@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59437 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157AbZLNMJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 07:09:47 -0500
In-Reply-To: <20091212084112.GA8948@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 12 December 2009, Herbert Xu wrote:
> On Thu, Dec 03, 2009 at 06:52:00PM +0100, Arnd Bergmann wrote:
> > This is a second prototype of a new interface into the network
> > stack, to eventually replace tun/tap and the bridge driver
> > in certain virtual machine setups. The code has changed
> > significantly, but the goals still remain.
> 
> The idea looks pretty sound to me.

Thanks!

> > I'm posting this mainly to solicit feedback. Not sure how
> > chances for integration into 2.6.33 are, given that the merge
> > window is opening already.
> 
> It's way too late for 2.6.33.  But the earlier this becomes ready
> then the earlier it can go into linux-next.

Right. Since the code is basically working (I have two known bugs
I'm still working on) and people want to test it, what is the
best path? I could
a) keep my git tree for myself,
b) have it added to linux-next,
c) prepare a combined patch for net-next.git, or
d) have it added to drivers/staging

	Arnd

