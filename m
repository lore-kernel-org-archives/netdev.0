From: Bill Fink <billfink@mindspring.com>
Subject: Re: Bonding support for eth1394?
Date: Sun, 14 Oct 2007 02:18:50 -0400
Message-ID: <20071014021850.9bd7c9ad.billfink@mindspring.com>
References: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>
	<47106EDE.1090601@s5r6.in-berlin.de> <adair5bm3jf.fsf@cisco.com>
	<4711087E.1050005@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4711087E.1050005@s5r6.in-berlin.de>
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

On Sat, 13 Oct 2007, Stefan Richter wrote:

> Roland Dreier wrote:
> > There are a few changes to the bonding driver pending that will add
> > support for bonding IP-over-InfiniBand interfaces.  IPoIB also cannot
> > change its HW address, so the patches address that issue.
> > 
> > Once those patches land, bonding eth1394 interfaces may "just work".
> 
> Sounds promising.  I will keep an eye on it.

While that might allow multiple eth1394 interfaces to be bonded,
I believe the user wanted to bond an eth1394 interface with a normal
Ethernet interface, and I don't think that will work even with the
IPoIB bonding changes, since bonding of different fundamental types
of network interfaces still won't be supported, and I'm pretty sure
eth1394 is not considered a standard Ethernet interface (different
MAC address format for one thing).

						-Bill

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
