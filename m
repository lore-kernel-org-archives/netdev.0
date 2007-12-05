From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 7/11] ibm_newemac: Skip EMACs that are marked unused by
	the firmware
Date: Wed, 05 Dec 2007 15:34:49 +1100
Message-ID: <1196829289.13230.358.camel@pasglop>
References: <20071205001539.97730DE091@ozlabs.org>
	<20071205035345.GA12855@localhost.localdomain>
	<1196828329.13230.356.camel@pasglop>
	<20071205042126.GE12855@localhost.localdomain>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071205042126.GE12855@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-12-05 at 15:21 +1100, David Gibson wrote:
> On Wed, Dec 05, 2007 at 03:18:49PM +1100, Benjamin Herrenschmidt wrote:
> > 
> > On Wed, 2007-12-05 at 14:53 +1100, David Gibson wrote:
> > > It occurred to me the other day.  Instead of using a new "unused"
> > > property for this, should we be using the OF standard "status"
> > > property.
> > 
> > Dunno... it's really not wired. Probably not even clocked.
> 
> status = "fail-notconnected"; ?

Bah, that's fugly.. jeff, don't hold the patches, we may sort that out
later.

Ben.
