From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 12:13:12 -0800
Message-ID: <20061129121312.4cfc254f@freekitty>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	<200611291612.33448.mb@bu3sch.de>
	<20061129152407.GB5412@devicescape.com>
	<200611291638.56759.mb@bu3sch.de>
	<20061129160328.GA22602@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net,
	Nick Kossifidis <mickflemm@gmail.com>, Michael Buesch <mb@bu3sch.de>
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061129160328.GA22602@devicescape.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006 08:03:28 -0800
David Kimdon <david.kimdon@devicescape.com> wrote:

> On Wed, Nov 29, 2006 at 04:38:56PM +0100, Michael Buesch wrote:
> > On Wednesday 29 November 2006 16:24, David Kimdon wrote:
> > > On Wed, Nov 29, 2006 at 04:12:33PM +0100, Michael Buesch wrote:
> > > > On Wednesday 29 November 2006 15:34, Nick Kossifidis wrote:
> > > Why do you say that?
> > > 
> > > There is absolutely no reason why dadwifi can't be merged into the
> > > mainline once the hal issue is resolved. 
> > 
> > Last time we talked about that stuff, it was decided that
> > we don't want a HAL... See archives.
> 
> To be clear, that is all part of the hal issue that needs to be
> resolved.  Removing the hal abstraction is not difficult for an
> interested party once source for the hal is available.  The next step
> in such an effort would be to add an open hal to dadwifi, IMO.
> 

Isn't it obvious. Planning from goal through intermediate steps gives:

0 - today (raw materials)
	* softmac stack: d80211
	* open hal: ar5k
	* glue layer: dadwifi

1- put pieces together
	* d80211 + dadwifi + ar5k

2 - release working code to d80211 tree

3 - hard link dad2ifi to ar5k (one module)

4 - collapse indirect calls and refactor

5 - lather rinse repeat in public d80211 tree

...

8 - resulting in atheros driver kernel module

9 - code ready in d80211


10 - mainline integration of working driver for Atheros
     using common softmac stack

> 
> P.S. Actually, it isn't clear to me that removing the hal entirely is
> a good idea.  Abstractions exist for practical reasons.  The hal
> allows dadwifi to support a variety of Atheros chips without needing
> to worry about the specific details of each chip.

Abstractions that deal with hardware are good. See phylib.
Abstractions that try to deal with operating system independence are 
gross.



-- 
Stephen Hemminger <shemminger@osdl.org>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
