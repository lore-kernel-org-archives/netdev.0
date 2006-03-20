From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 12:53:35 +0100
Message-ID: <1142855615.3114.33.camel@laptopd505.fenrus.org>
References: <20060320090629.GA11352@mellanox.co.il>
	<20060320.015500.72136710.davem@davemloft.net>
	<20060320102234.GV29929@mellanox.co.il>
	<20060320.023704.70907203.davem@davemloft.net>
	<20060320112753.GX29929@mellanox.co.il>
	<1142855223.3114.30.camel@laptopd505.fenrus.org>
	<20060320114933.GA3058@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060320114933.GA3058@xi.wantstofly.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-20 at 12:49 +0100, Lennert Buytenhek wrote:
> On Mon, Mar 20, 2006 at 12:47:03PM +0100, Arjan van de Ven wrote:
> 
> > > > I disagree with Linux changing it's behavior.  It would be great to
> > > > turn off congestion control completely over local gigabit networks,
> > > > but that isn't determinable in any way, so we don't do that.
> > > 
> > > Interesting. Would it make sense to make it another tunable knob in
> > > /proc, sysfs or sysctl then?
> > 
> > that's not the right level; since that is per interface. And you only
> > know the actual interface waay too late (as per earlier posts).
> > Per socket.. maybe
> > But then again it's not impossible to have packets for one socket go out
> > to multiple interfaces
> > (think load balancing bonding over 2 interfaces, one IB another
> > ethernet)
> 
> I read it as if he was proposing to have a sysctl knob to turn off
> TCP congestion control completely (which has so many issues it's not
> even funny.)

owww that's so bad I didn't even consider that
