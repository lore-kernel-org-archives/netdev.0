From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 13:16:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15786.42910.601886.468716@robur.slu.se>
References: <3DA82269.CBB65E89@isg.de>
	<20021014103855.GA19962@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20021014103855.GA19962@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


bert hubert writes:
 > On Sat, Oct 12, 2002 at 03:23:53PM +0200, Stefan Rompf wrote:
 > 
 > > +CONFIG_LINKWATCH
 > > +  When this option is enabled, the kernel will forward changes in the
 > > +  operative ("RUNNING") state of an interface via the netlink socket.
 > > +  This is most useful when running linux as a router.
 > 
 > I know people who would kill for this feature. So powers that be, please
 > consider merging.
 > 
 > Is there no quick way of getting all cards using the MII stuff to support
 > this in one go? mii-diag seems to work on most cards already?

 Hello!

 Well it has to be handled with somewhat caution too... Just a little link-flap 
 can cause massive network/routing changes.

 If you run a routing protocol BGP, OSPF etc it has it's own mechanism with 
 timers for declaring neighbours/link partners down. But yes in some setups it 
 can be useful -- with dampning.

							--ro
 

 PS. Have seen 100 kpps in a Linux production router now. :-)

 
