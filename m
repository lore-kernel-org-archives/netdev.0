From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] macvlan: add tap device backend
Date: Sat, 12 Dec 2009 16:41:12 +0800
Message-ID: <20091212084112.GA8948@gondor.apana.org.au>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de> <1259862720-28432-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757594AbZLLIlu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1259862720-28432-3-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2009 at 06:52:00PM +0100, Arnd Bergmann wrote:
> This is a second prototype of a new interface into the network
> stack, to eventually replace tun/tap and the bridge driver
> in certain virtual machine setups. The code has changed
> significantly, but the goals still remain.

The idea looks pretty sound to me.
 
> I'm posting this mainly to solicit feedback. Not sure how
> chances for integration into 2.6.33 are, given that the merge
> window is opening already.

It's way too late for 2.6.33.  But the earlier this becomes ready
then the earlier it can go into linux-next.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
