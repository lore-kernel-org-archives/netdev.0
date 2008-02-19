From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Bonding support for eth1394?
Date: Tue, 19 Feb 2008 22:27:55 +0100
Message-ID: <47BB49DB.3060204@s5r6.in-berlin.de>
References: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>	<47106EDE.1090601@s5r6.in-berlin.de>	<adair5bm3jf.fsf@cisco.com>	<4711087E.1050005@s5r6.in-berlin.de>	<20071014021850.9bd7c9ad.billfink@mindspring.com>	<471201D7.8090001@s5r6.in-berlin.de>
	<47139D28.9010303@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	Rick Jones <rick.jones2@hp.com>,
	linux1394-devel@lists.sourceforge.net,
	Roland Dreier <rdreier@cisco.com>
To: Karl Svec <karlsvec@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47139D28.9010303@hp.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Roland Dreier wrote on 2007-10-13:
>  > The bonding sources have a few occurrences of EOPNOTSUPP.  Unless I
>  > missed something, they are all related to setting the hardware address
>  > of the interface.  AFAICS this is impossible with IP over FireWire.  If
>  > it is crucial to bonding to be able to change the slaves' hardware
>  > addresses, then you are out of luck.
> 
> There are a few changes to the bonding driver pending that will add
> support for bonding IP-over-InfiniBand interfaces.  IPoIB also cannot
> change its HW address, so the patches address that issue.
> 
> Once those patches land, bonding eth1394 interfaces may "just work".

Bill Fink wrote on 2007-10-14:
> While that might allow multiple eth1394 interfaces to be bonded,
> I believe the user wanted to bond an eth1394 interface with a normal
> Ethernet interface, and I don't think that will work even with the
> IPoIB bonding changes, since bonding of different fundamental types
> of network interfaces still won't be supported, and I'm pretty sure
> eth1394 is not considered a standard Ethernet interface (different
> MAC address format for one thing).


Karl, you could try kernel 2.6.24(.2) which AFAIU features the mentioned 
changes.
-- 
Stefan Richter
-=====-==--- --=- =--==
http://arcgraph.de/sr/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
