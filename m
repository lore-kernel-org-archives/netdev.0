From: jamal <hadi@cyberus.ca>
Subject: Re: 1.03Mpps on e1000 (was: Re: Transmission limit)
Date: 06 Dec 2004 06:32:37 -0500
Message-ID: <1102332757.1042.2255.camel@jzny.localdomain>
References: <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041201182943.GA14470@xi.wantstofly.org>
	 <20041201213550.GF14470@xi.wantstofly.org>
	 <1101967983.4782.9.camel@localhost.localdomain>
	 <20041205145051.GA647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
	 <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
	 <20041205174401.GJ647@xi.wantstofly.org>
	 <20041205175133.GK647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051852340.29474@tux.rsn.bth.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, Scott Feldman <sfeldma@pobox.com>, Robert Olsson <Robert.Olsson@data.slu.se>,  P@draigBrady.com, mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,  Jorge Manuel Finochietto <jorge.finochietto@polito.it>, Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <Pine.LNX.4.58.0412051852340.29474@tux.rsn.bth.se>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 12:54, Martin Josefsson wrote:
> On Sun, 5 Dec 2004, Lennert Buytenhek wrote:
> 
> > I've tested all packet sizes now, and delayed TDT updating once per jiffy
> > (instead of once per packet) indeed gives about 25kpps more on 60,61,62
> > byte packets, and is hardly worth it for bigger packets.
> 
> Maybe we can't see any real gains here now, I wonder if it has any effect
> if you have lots of nics on the same bus. I mean, in theory it saves a
> whole lot of traffic on the bus.
> 

This sounds like really exciting stuff happening here over the weekend.
Scott, you had to leave Intel before giving us this tip? ;-> 

Someone correct me if i am wrong - but does it appear as if all these
changes are only useful on PCI but not PCI-X?

cheers,
jamal



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
